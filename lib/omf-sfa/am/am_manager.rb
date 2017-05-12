require 'rdf'
require 'omf_common/lobject'
require 'omf-sfa/am'
require 'nokogiri'
require 'active_support/inflector' # for classify method
require_relative '../omn-models/resource'
require_relative '../omn-models/account'
require_relative '../samant_models/anyURItype'
#require_relative '../omn-models/populator'
#require_relative '../samant_models/sensor.rb'
#require_relative '../samant_models/uxv.rb'

module OMF::SFA::AM

  class AMManagerException < Exception; end
  class UnknownResourceException < AMManagerException; end
  class UnavailableResourceException < AMManagerException; end
  class UnknownAccountException < AMManagerException; end
  class FormatException < AMManagerException; end
  class ClosedAccountException < AMManagerException; end
  class InsufficientPrivilegesException < AMManagerException; end
  class UnavailablePropertiesException < AMManagerException; end
  class MissingImplementationException < Exception; end
  class UknownLeaseException < Exception; end

  # Namespace used for reservation information
  OL_NAMESPACE = "http://nitlab.inf.uth.gr/schema/sfa/rspec/1"
  OL_SEMANTICNS = "http://open-multinet.info/ontology/omn-lifecycle#hasLease"
  RES_SEMANTICNS = "http://open-multinet.info/ontology/omn#hasResource"
  OMNstartTime = "http://open-multinet.info/ontology/omn-lifecycle#startTime"
  OMNexpirationTime = "http://open-multinet.info/ontology/omn-lifecycle#expirationTime"
  OMNlease = "http://open-multinet.info/ontology/omn-lifecycle#Lease/"
  OMNcomponentID = "http://open-multinet.info/ontology/omn-lifecycle#hasComponentID"
  OMNcomponentName = "http://open-multinet.info/ontology/omn-lifecycle#hasComponentName"
  OMNID =  "http://open-multinet.info/ontology/omn-lifecycle#hasID"
  W3type = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  W3label = "http://www.w3.org/2000/01/rdf-schema#label"

  # The manager is where all the AM related policies and
  # resource management is concentrated. Testbeds with their own
  # ways of dealing with resources and components should only
  # need to extend this class.
  #
  class AMManager < OMF::Common::LObject
    attr_accessor :liaison
    # Create an instance of this manager
    #
    # @param [Scheduler] scheduler to use for creating new resource
    #
    def initialize(scheduler)
      @scheduler = scheduler
    end

    # It returns the default account, normally used for admin account.
    def _get_nil_account()
      @scheduler.get_nil_account()
    end

    def get_scheduler()
      @scheduler
    end

    ### MANAGEMENT INTERFACE: adding and removing from the AM's control

    # Register a resource to be managed by this AM.
    #
    # @param [OResource] resource to be managed by this manager
    #
    def manage_resource(resource)
      unless resource.is_a?(OMF::SFA::Model::Resource)
        raise "Resource '#{resource}' needs to be of type 'Resource', but is '#{resource.class}'"
      end

      resource.account_id = _get_nil_account.id
      resource.save
      resource
    end

    # Register an array of resources to be managed by this AM.
    #
    # @param [Array] array of resources
    #
    def manage_resources(resources)
      resources.map {|r| manage_resource(r) }
    end

    ### ACCOUNTS: creating, finding, and releasing accounts

    # Return the account described by +account_descr+. Create if it doesn't exist.
    #
    # @param [Hash] properties of account
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Account] The requested account
    # @raise [UnknownResourceException] if requested account cannot be created
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def find_or_create_account(account_descr, authorizer)
      debug "find_or_create_account: '#{account_descr.inspect}'"
      begin
        account = find_account(account_descr, authorizer)
        return account
      rescue UnavailableResourceException # to raise tou exception exei ginei stin find_account => an den uparxei to account
        raise InsufficientPrivilegesException.new unless authorizer.can_create_account? # tsek an mporei na dimiourgisei account
        account = OMF::SFA::Model::Account.create(account_descr) # dimiourgise to, INSERT INTO ...
        # Ask the corresponding RC to create an account
        @liaison.create_account(account)
      end
      
      raise UnavailableResourceException.new "Cannot create '#{account_descr.inspect}'" unless account
      account
    end

    # Return the account described by +account_descr+.
    #
    # @param [Hash] properties of account
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Account] The requested account
    # @raise [UnknownResourceException] if requested account cannot be found
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def find_account(account_descr, authorizer)
      unless account = OMF::SFA::Model::Account.first(account_descr) # tsek an uparxei
        raise UnavailableResourceException.new "Unknown account '#{account_descr.inspect}'" # to rescue ginetai se autin pou tin kalei
      end
      raise InsufficientPrivilegesException.new unless authorizer.can_view_account?(account) # tsek an mporei na ton dei
      account # epistrepse ton
    end

    # Return all accounts visible to the requesting user
    #
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Array<Account>] The visible accounts (maybe empty)
    #
    def find_all_accounts(authorizer)
      accounts = OMF::SFA::Model::Account.exclude(:name => '__default__') # gurnaei array me ola ta accounts ektos apo to default
      accounts.map do |a| #san tin array.each, xreiazetai gia na ektelestei to query
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_account?(a)
          a
        rescue InsufficientPrivilegesException
          nil
        end
      end.compact
    end

    # Renew account described by +account_descr+ hash until +expiration_time+.
    #
    # @param [Hash] properties of account or account object
    # @param [Time] time until account should remain valid
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Account] The requested account
    # @raise [UnknownResourceException] if requested account cannot be found
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def renew_account_until(account_descr, expiration_time, authorizer)
      if account_descr.is_a?(OMF::SFA::Model::Account) # an sto description exei do8ei account
        account = account_descr
      else
        account = find_account(account_descr, authorizer)
      end
      raise InsufficientPrivilegesException unless authorizer.can_renew_account?(account, expiration_time)
      debug " new expiration time = " + expiration_time.to_s
      account.open if account.closed?
      account.valid_until = expiration_time
      account.save
      debug " new valid until = " + account.valid_until.to_s
      # Ask the corresponding RC to create/re-open an account
      @liaison.create_account(account)

      account
    end

    # Close the account described by +account+ hash.
    #
    # Make sure that all associated components are freed as well
    #
    # @param [Hash] properties of account
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Account] The closed account
    # @raise [UnknownResourceException] if requested account cannot be found
    # @raise [UnavailableResourceException] if requested account is closed
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def close_account(account_descr, authorizer)
      if account_descr.is_a?(OMF::SFA::Model::Account)
        account = account_descr
      else
        account = find_account(account_descr, authorizer)
      end
      raise InsufficientPrivilegesException unless authorizer.can_close_account?(account)

      #release_all_components_for_account(account, authorizer)
      release_all_leases_for_account(account, authorizer)

      account.close

      @liaison.close_account(account)
      account
    end

    def close_samant_account(slice_descr, authorizer)
      # TODO A LOT OF WORK ON THIS CONCEPT
      release_all_samant_leases_for_account(slice_descr, authorizer)
    end

    ### USERS

    # Return the user described by +user_descr+. Create if it doesn't exist.
    # Reset its keys if an array of ssh-keys is given
    #
    # Note: This is an unprivileged  operation as creating a user doesn't imply anything
    # else beyond opening a record.
    #
    # @param [Hash] properties of user
    # @return [User] The requested user
    # @raise [UnknownResourceException] if requested user cannot be created
    #
    def find_or_create_user(user_descr, keys = nil)
      debug "find_or_create_user: '#{user_descr.inspect}'"
      begin
        user = find_user(user_descr)
      rescue UnavailableResourceException
        user = OMF::SFA::Model::User.create(user_descr)
      end
      unless keys.nil?
        user.keys.each { |k| k.destroy }
        keys.each do |k|
          key = OMF::SFA::Model::Key.create(ssh_key: k)
          user.add_key(key) # dhmiourgei ssh key kai to ana8etei ston user
        end
      end
      raise UnavailableResourceException.new "Cannot create '#{user_descr.inspect}'" unless user
      user.save
      user
    end

    # Return the user described by +user_descr+.
    #
    # @param [Hash] properties of user
    # @return [User] The requested user
    # @raise [UnknownResourceException] if requested user cannot be found
    #
    def find_user(user_descr)
      unless user = OMF::SFA::Model::User.first(user_descr) # epistrefei to prwto occurence tou user stin Sequel vasi
        raise UnavailableResourceException.new "Unknown user '#{user_descr.inspect}'"
      end
      user
    end

    ### LEASES: creating, finding, and releasing leases

    # Return the lease described by +lease_descr+.
    #
    # @param [Hash] properties of lease
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Lease] The requested lease
    # @raise [UnknownResourceException] if requested lease cannot be found
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def find_lease(lease_descr, authorizer)
      debug "find lease:  '#{lease_descr.inspect}'"
      unless lease = OMF::SFA::Model::Lease.first(lease_descr)
        #debug "edw eimai" + lease.inspect
        raise UnavailableResourceException.new "Unknown lease '#{lease_descr.inspect}'" # an to lease pou dimiourgeis den uparxei gyrnaei auto
      end
      raise InsufficientPrivilegesException unless authorizer.can_view_lease?(lease) # den kserw pou einai
      lease
    end

    def find_samant_lease(lease_uuid, authorizer)
      debug "find samant lease:  '#{lease_uuid}'"
      lease_uri = RDF::URI.new("uuid:"+lease_uuid)
      sparql = SPARQL::Client.new($repository)
      unless sparql.ask.whether([lease_uri, :p, :o]).true?
        debug "Lease with uuid #{lease_uuid.inspect} doesn't exist."
        raise UnavailableResourceException.new "Unknown lease with uuid'#{lease_uuid.inspect}'"
      end
      raise InsufficientPrivilegesException unless authorizer.can_view_lease?(lease_uuid)
      lease = SAMANT::Lease.for(lease_uri)
      debug "Lease Exists with ID = " + lease.hasID.inspect
      return lease
    end

    # Return the lease described by +lease_descr+. Create if it doesn't exist.
    #
    # @param [Hash] lease_descr properties of lease
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Lease] The requested lease
    # @raise [UnknownResourceException] if requested lease cannot be created
    # @raise [InsufficientPrivilegesException] if permission is not granted
    #
    def find_or_create_lease(lease_descr, authorizer)
      debug "find_or_create_lease: '#{lease_descr.inspect}'"
      begin
        return find_lease(lease_descr, authorizer) # an uparxei epistrepse to
      rescue UnavailableResourceException
      end
      raise InsufficientPrivilegesException unless authorizer.can_create_resource?(lease_descr, 'lease') # am_authorizer
      lease = OMF::SFA::Model::Lease.create(lease_descr) # alliws dimiourgise to

      raise UnavailableResourceException.new "Cannot create '#{lease_descr.inspect}'" unless lease
      @scheduler.add_lease_events_on_event_scheduler(lease) 
      @scheduler.list_all_event_scheduler_jobs #debug messages only
      lease
      # lease = create_resource(lease_descr, 'Lease', lease_properties, authorizer)
    end

    def find_or_create_samant_lease(lease_uuid, lease_descr, authorizer)
      debug "find_or_create_samant_lease: '#{lease_descr.inspect}' " + " uuid: " + lease_uuid.inspect
      begin
        return find_samant_lease(lease_uuid, authorizer)
      rescue UnavailableResourceException
      end
      raise InsufficientPrivilegesException unless authorizer.can_create_resource?(lease_descr, 'lease') # to lease_descr den xrisimopoieitai
      # CREATE LEASE
      lease_uri = ("uuid:" + lease_uuid).to_sym
      lease = SAMANT::Lease.for(lease_uri, lease_descr)
      #debug "clientid = " + lease_descr[:client_id]
      #lease.clientID = lease_descr[:client_id]
      lease.save!
      debug "new lease = " + lease.inspect
      debug "new lease startTime = " + lease.startTime.inspect
      debug "new lease clientId = " + lease.clientID.inspect
      raise UnavailableResourceException.new "Cannot create '#{lease_descr.inspect}'" unless lease
      @scheduler.add_samant_lease_events_on_event_scheduler(lease)
      @scheduler.list_all_event_scheduler_jobs
      lease
    end

    # Find al leases if no +account+ and +status+ is given
    #
    # @param [Account] filter the leases by account
    # @param [Status] filter the leases by their status ['pending', 'accepted', 'active', 'past', 'cancelled']
    # @param [Authorizer] Authorization context
    # @return [Lease] The requested leases
    #
    def find_all_leases(account = nil, status = ['pending', 'accepted', 'active', 'past', 'cancelled'], authorizer)
      debug "find_all_leases: account: #{account.inspect} status: #{status}"
      if account.nil?
        leases = OMF::SFA::Model::Lease.where(status: status) # gurnaei pinaka me ola ta leases pou antistoixoun sto (default) account
      else
        leases = OMF::SFA::Model::Lease.where(account_id: account.id, status: status)
      end
      leases.map do |l|
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_lease?(l)
          l
        rescue InsufficientPrivilegesException
          nil
        end
      end.compact
    end

    # !!!SAMANT PROJECT ADDITION!!!
    #
    # Find all leases if +account+ and +state+ is given
    #
    # @param [Account] filter the leases by account
    # @param [State] filter the leases by their status ['pending', 'accepted', 'active', 'past', 'cancelled']
    # @param [Authorizer] Authorization context
    # @return [Lease] The requested leases
    #

    def find_all_samant_leases(account_urn = nil, state = [SAMANT::ALLOCATED, SAMANT::PROVISIONED, SAMANT::UNALLOCATED, SAMANT::CANCELLED, SAMANT::PENDING], authorizer)

      debug "find_all_samant_leases: account: #{authorizer.account.inspect} status: #{state.inspect}"
      debug "find_all_samant_leases: authorizer: #{authorizer.inspect} "
      debug "authorizer urn = " + authorizer.account[:urn].inspect unless authorizer.account.nil?

      if account_urn.nil?
        if state.kind_of?(Array)
          leases = []
          state.each { |istate|
            leases << SAMANT::Lease.find(:all, :conditions => {:hasReservationState => istate.to_uri})
          }
          leases.flatten!
        else
          leases = SAMANT::Lease.find(:all, :conditions => {:hasReservationState => state.to_uri})
        end
      else
        # debug "slice account_urn = " + account_urn[:urn].inspect
        # debug "slice authorizer.account[:urn] = " + authorizer.account[:urn].inspect
        raise InsufficientPrivilegesException unless account_urn == authorizer.account[:urn] || authorizer.account[:urn] == "urn:publicid:IDN+omf:netmode+account+__default__"

        # raise InsufficientPrivilegesException unless account_urn[:urn] == authorizer.account[:urn]
        if state.kind_of?(Array)
          leases = []
          state.each { |istate|
            leases << SAMANT::Lease.find(:all, :conditions => {:hasSliceID => account_urn, :hasReservationState => istate.to_uri})
          }
          leases.flatten!
        else

          leases = SAMANT::Lease.find(:all, :conditions => {:hasSliceID => account_urn, :hasReservationState => state.to_uri})
        end
      end
      debug 'eftasa edo!!!! '
      debug authorizer.can_view_lease?
      debug 'telos'

      leases.map do |l| # den paizei rolo to kathe lease pou pernaw san parametro, logika typiko
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_lease?(l)
          l
        rescue InsufficientPrivilegesException
          nil
        end
      end
    end



    def find_all_samant_leases_rpc(account_urn = nil, state = [SAMANT::ALLOCATED, SAMANT::PROVISIONED, SAMANT::UNALLOCATED, SAMANT::CANCELLED, SAMANT::PENDING], authorizer)

      debug "find_all_samant_leases: account: #{authorizer.account.inspect} status: #{state.inspect}"
      # debug "find_all_samant_leases: authorizer: #{authorizer.inspect} "
      debug "authorizer urn = " + authorizer.account[:urn].inspect unless authorizer.account.nil?

      if account_urn.nil?
        if state.kind_of?(Array)
          leases = []
          state.each { |istate|
            leases << SAMANT::Lease.find(:all, :conditions => {:hasReservationState => istate.to_uri})
          }
          leases.flatten!
        else
          leases = SAMANT::Lease.find(:all, :conditions => {:hasReservationState => state.to_uri})
        end
      else
        # debug "slice account_urn = " + account_urn[:urn].inspect
        # debug "slice authorizer.account[:urn] = " + authorizer.account[:urn].inspect
        # raise InsufficientPrivilegesException unless account_urn == authorizer.account[:urn]
        raise InsufficientPrivilegesException unless account_urn[:urn] == authorizer.account[:urn]
        if state.kind_of?(Array)
          leases = []
          state.each { |istate|
            leases << SAMANT::Lease.find(:all, :conditions => {:hasSliceID => account_urn[:urn], :hasReservationState => istate.to_uri})
          }
          leases.flatten!
        else

          leases = SAMANT::Lease.find(:all, :conditions => {:hasSliceID => account_urn[:urn], :hasReservationState => state.to_uri})
        end
      end
      debug 'eftasa edo!!!! '
      debug authorizer.can_view_lease?
      debug 'telos'

      leases.map do |l| # den paizei rolo to kathe lease pou pernaw san parametro, logika typiko
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_lease?(l)
          l
        rescue InsufficientPrivilegesException
          nil
        end
      end
    end



    # Modify lease described by +lease_descr+ hash
    #
    # @param [Hash] lease properties like ":valid_from" and ":valid_until"
    # @param [Lease] lease to modify
    # @param [Authorizer] Authorization context
    # @return [Lease] The requested lease
    #
    def modify_lease(lease_properties, lease, authorizer)
      raise InsufficientPrivilegesException unless authorizer.can_modify_lease?(lease)
      lease.update(lease_properties) # datamapper update, resource
      @scheduler.update_lease_events_on_event_scheduler(lease)
      lease
    end

    def modify_samant_lease(lease_properties, lease, authorizer)
      # prepei na ftiaksw tin can_modify_samant_lease?
      raise InsufficientPrivilegesException unless authorizer.can_modify_samant_lease?(lease)
      # to time einai parsed!!!!
      # debug "before update: " + lease.startTime.inspect
      lease.update_attributes(lease_properties)
      # debug "after update: " + lease.startTime.inspect
      @scheduler.update_samant_lease_events_on_event_scheduler(lease)
      lease
      #raise OMF::SFA::AM::Rest::BadRequestException.new "MODIFIER NOT YET IMPLEMENTED"
    end

    # cancel +lease+
    #
    # This implementation simply frees the lease record
    # and destroys any child components if attached to the lease
    #
    # @param [Lease] lease to release
    # @param [Authorizer] Authorization context
    #
    def release_lease(lease, authorizer)
      debug "release_lease: lease:'#{lease.inspect}' authorizer:'#{authorizer.inspect}'"
      raise InsufficientPrivilegesException unless authorizer.can_release_lease?(lease)
      @scheduler.release_lease(lease) # destroy & diagrafi apo ton event scheduler
    end

    def release_samant_lease(lease, authorizer)
      debug "release_samant_lease: lease:'#{lease.inspect}' authorizer:'#{authorizer.inspect}'"
      raise InsufficientPrivilegesException unless authorizer.can_release_samant_lease?(lease)
      @scheduler.release_samant_lease(lease) # destroy & diagrafi apo ton event scheduler
    end

    # Release an array of leases.
    #
    # @param [Array<Lease>] Leases to release
    # @param [Authorizer] Authorization context
    def release_leases(leases, authorizer)
      leases.each do |l|
        release_lease(l, authorizer)
      end
    end

    def release_samant_leases(leases, authorizer)
      leases.each do |l|
        release_samant_lease(l, authorizer)
      end
    end

    # This method finds all the leases of the specific account and
    # releases them.
    #
    # @param [Account] Account who owns the leases
    # @param [Authorizer] Authorization context
    #
    def release_all_leases_for_account(account, authorizer)
      leases = find_all_leases(account, ['accepted', 'active'], authorizer) # ola ta leases tou do8entos account
      release_leases(leases, authorizer)
    end

    def release_all_samant_leases_for_account(slice_urn, authorizer)
      leases = find_all_samant_leases(slice_urn, [SAMANT::ALLOCATED, SAMANT::PROVISIONED], authorizer)# ola ta leases tou do8entos account
      release_samant_leases(leases, authorizer)
    end


    ### RESOURCES creating, finding, and releasing resources


    # Find a resource. If it doesn't exist throws +UnknownResourceException+
    # If it's not visible to requester throws +InsufficientPrivilegesException+
    #
    # @param [Hash, Resource] describing properties of the requested resource
    # @param [String] The type of resource we are trying to find
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Resource] The resource requested
    # @raise [UnknownResourceException] if no matching resource can be found
    # @raise [FormatException] if the resource description is not Hash
    # @raise [InsufficientPrivilegesException] if the resource is not visible to the requester
    #
    #
    def find_resource(resource_descr, resource_type, authorizer, semantic = false) # h perigrafi tou dinetai eite se hash eite se model resource
      debug "find_resource: descr: '#{resource_descr.inspect}'" #synithws mas ta xalaei sto account_id, den prepei na einai managed apo kapoio slice, prepei na einai managed apo ton aggregate manager
      debug resource_type # px Location
      #debug "semantic = " + semantic
      if resource_descr.kind_of? OMF::SFA::Model::Resource
        resource = resource_descr # trivial?
      elsif resource_descr.kind_of? Hash
        if semantic
          debug "semantic attribute find" # TODO 1.DOESNT WORK FOR DECIMAL ATTRIBUTE & 2. SEARCH VIA ID
          sparql = SPARQL::Client.new($repository)
          res = eval("Semantic::#{resource_type.camelize}").find(:all, :conditions => resource_descr).first
          return sparql.construct([res.uri, :p,  :o]).where([res.uri, :p, :o])
        else
          resource = eval("OMF::SFA::Model::#{resource_type.camelize}").first(resource_descr) # vres to prwto pou tairiazei stin perigrafi
        end
      else
        raise FormatException.new "Unknown resource description type '#{resource_descr.class}' (#{resource_descr})"
      end
      unless resource
        raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' is not available or doesn't exist"
      end
      raise InsufficientPrivilegesException unless authorizer.can_view_resource?(resource)
      resource
    end

    def find_samant_resource(resource_descr, resource_type, authorizer)
      debug "find_samant_resource: descr: '#{resource_descr.inspect}' + resource type:" + resource_type.camelize
      if resource_descr.kind_of? Hash
        #resource_descr = resource_descr.except(:comp_id)
        #resource = eval("SAMANT::#{resource_type.camelize}").find(:all, :conditions => resource_descr).first
        resource = SAMANT::Uxv.find(:all, :conditions => resource_descr).first
        #uxv_urn = RDF::URI.new(resource_descr[:comp_id])
        #sparql = SPARQL::Client.new($repository)
        unless resource
          debug "There is no UxV with resource description: " + resource_descr.inspect
          raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' is not available or doesn't exist"
        end
        #resource = eval("SAMANT::#{resource_type}").for(resource_descr[:comp_id])
        debug "Resource = " + resource.inspect
      else
        raise FormatException.new "Unknown resource description type '#{resource_type}' (#{resource_descr})"
      end
      #unless resource
      #  raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' is not available or doesn't exist"
      #end
      raise InsufficientPrivilegesException unless authorizer.can_view_resource?(resource)
      resource
      # raise OMF::SFA::AM::Rest::BadRequestException.new "find RESOURCES NOT YET IMPLEMENTED"
    end

    # Find all the resources that fit the description. If it doesn't exist throws +UnknownResourceException+
    # If it's not visible to requester throws +InsufficientPrivilegesException+
    #
    # @param [Hash] describing properties of the requested resource
    # @param [String] The type of resource we are trying to find
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Resource] The resource requested
    # @raise [UnknownResourceException] if no matching resource can be found
    # @raise [FormatException] if the resource description is not Hash
    # @raise [InsufficientPrivilegesException] if the resource is not visible to the requester
    #
    #
    def find_all_resources(resource_descr, resource_type, authorizer, semantic = false)
      debug "find_resources: descr: '#{resource_descr.inspect}'"

      if resource_descr.kind_of? Hash

        # EXW PEIRAKSEI

        if semantic
          debug "semantic attribute find" # TODO 1.DOESNT WORK FOR DECIMAL ATTRIBUTE & 2. SEARCH VIA ID &
          sparql = SPARQL::Client.new($repository)
          res = eval("Semantic::#{resource_type.camelize}").find(:all, :conditions => resource_descr)
          resources = []
          res.each { |r|
            resources << sparql.construct([r.uri, :p,  :o]).where([r.uri, :p, :o])
          }
          return resources
          ############
        else
          resources = eval("OMF::SFA::Model::#{resource_type.classify}").where(resource_descr)
        end
      else
        raise FormatException.new "Unknown resource description type '#{resource_descr.class}' (#{resource_descr})"
      end
      raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' is not available or doesn't exist" if resources.nil? || resources.empty?


      resources.map do |r|
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
          r
        rescue InsufficientPrivilegesException
          nil
        end
      end.compact
    end

    # Find all components matching the resource description that are not leased for the given timeslot.
    # If it doesn't exist, or is not visible to requester
    # throws +UnknownResourceException+.
    #
    # @param [Hash] description of components
    # @param [String] The type of components we are trying to find
    # @param [String, Time] beggining of the timeslot 
    # @param [String, Time] ending of the timeslot
    # @return [Array] All availlable components
    # @raise [UnknownResourceException] if no matching resource can be found
    #
    def find_all_available_components(component_descr = {}, component_type, valid_from, valid_until, authorizer)
      debug "find_all_available_components: descr: '#{component_descr.inspect}', from: '#{valid_from}', until: '#{valid_until}'"
      component_descr[:account_id] = _get_nil_account.id
      components = find_all_resources(component_descr, component_type, authorizer) # vres ta components
      
      components = components.select do |res|
        @scheduler.component_available?(res, valid_from, valid_until) # des an einai available
      end

      raise UnavailableResourceException if components.empty?
      components
    end

    # Find a number of components matching the resource description that are not leased for the given timeslot.
    # If it doesn't exist, or is not visible to requester
    # throws +UnknownResourceException+.
    #
    # @param [Hash] description of components
    # @param [String] The type of components we are trying to find
    # @param [String, Time] beggining of the timeslot 
    # @param [String, Time] ending of the timeslot
    # @param [Array] array of component uuids that are not eligible to be returned by this function 
    # @param [Integer] number of available components to be returned by this function
    # @return [Array] All availlable components
    # @raise [UnknownResourceException] if no matching resource can be found
    #
    def find_available_components(component_descr, component_type, valid_from, valid_until, non_valid_component_uuids = [], nof_requested_components = 1, authorizer)
      debug "find_all_available_components: descr: '#{component_descr.inspect}', from: '#{valid_from}', until: '#{valid_until}'"
      component_descr[:account_id] = _get_nil_account.id
      components = find_all_resources(component_descr, component_type, authorizer)
      components.shuffle! # this randomizes the result
      
      output = []
      components.each do |comp|
        next if non_valid_component_uuids.include?(comp.uuid)
        output << comp if @scheduler.component_available?(comp, valid_from, valid_until) 
        break if output.size >= nof_requested_components
      end

      raise UnavailableResourceException if output.size < nof_requested_components
      output
    end

    # Find all resources for a specific account. Return the managed resources
    # if no account is given
    #
    # @param [Account] Account for which to find all associated resources
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Array<Resource>] The resource requested
    #
    def find_all_resources_for_account(account = nil, semantic = false, authorizer)
      debug "find_all_resources_for_account: #{account.inspect}"

      if semantic
        #res = Semantic::Resource.where({:address => "192.168.12.1"}).first.address#account_id: account.id) #construct query
        debug "i m in semantic!"
        account = Semantic::Account.for(:nil_account) if account.nil? # vres ton default account
        sparql = SPARQL::Client.new($repository)
        res = sparql.construct([:s, :p, account.uri]).where([:s, :p, account.uri]) # query pou gyrnaei ola ta nodes pou diaxeirizetai to nil account
        # TODO check priviledges!!

      else
        account = _get_nil_account if account.nil? # nill account id = 2
        res = OMF::SFA::Model::Resource.where(account_id: account.id) # enas pinakas me ola ta resources tou sugkekrimenou id
        res.map do |r|
          begin
            raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
            r
          rescue InsufficientPrivilegesException
            nil
          end
        end.compact
      end
      res
    end

    # Find all components for a specific account. Return the managed components
    # if no account is given
    #
    # @param [Account] Account for which to find all associated component
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Array<Component>] The component requested
    #
    def find_all_components_for_account(account = _get_nil_account, authorizer)
      debug "find_all_components_for_account: #{account.inspect}"
      res = OMF::SFA::Model::Component.where(:account_id => account.id)
      res.map do |r|
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
          r
        rescue InsufficientPrivilegesException
          nil
        end
      end.compact
    end

    # !!!SAMANT PROJECT ADDITION!!!
    #
    # Find all components for a specific account. Return the managed components
    # if no account is given
    #
    # @param [Account] Account for which to find all associated component
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Array<Component>] The component requested
    #

    def find_all_samant_components_for_account(account_urn = nil, authorizer)
      debug "find_all_samant_components_for_account: #{account_urn}"
      debug "find_all_samant_components_for_account  authorizer.account[:urn]: #{ authorizer.account[:urn]}"

      res = []
      ifr = [] # interfaces
      snr = []
      lct = []
      if account_urn.nil?
      # if authorizer.account[:urn].nil?
        res << SAMANT::Uxv.find(:all)
      else
        raise InsufficientPrivilegesException unless account_urn == authorizer.account[:urn] || authorizer.account[:urn] == "urn:publicid:IDN+omf:netmode+account+__default__"
        # raise InsufficientPrivilegesException unless account_urn[:urn] == authorizer.account[:urn]

        # res << SAMANT::Uxv.find(:all, :conditions => {:hasSliceID => authorizer.account[:urn]})
        res << SAMANT::Uxv.find(:all, :conditions => {:hasSliceID => account_urn})
      end
      res.flatten!
      res.map do |r|
        # Check for Interfaces & Sensors & Locations (Used in Rspec)
        snr << r.hasSensorSystem
        ifr << r.hasInterface
        lct << r.where
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
          r
        rescue InsufficientPrivilegesException
          nil
        end
      end
      ifr.flatten!
      #debug "@@@@@Interfaces: " + ifr.inspect
      #debug "@@@@@Sensors: " + snr.inspect
      #debug "@@@@@Locations: " + lct.inspect
      res << ifr << lct
      res.flatten!
    end

    def find_all_samant_components_for_account_rpc(account_urn = nil, authorizer)
      debug "find_all_samant_components_for_account: #{account_urn}"
      # debug "find_all_samant_components_for_account authorizer.account[:urn]: #{authorizer.account[:urn]}"
      res = []
      ifr = [] # interfaces
      snr = []
      lct = []
      if account_urn.nil?
        # if authorizer.account[:urn].nil?
        res << SAMANT::Uxv.find(:all)
      else
        # raise InsufficientPrivilegesException unless account_urn == authorizer.account[:urn]
        raise InsufficientPrivilegesException unless account_urn[:urn] == authorizer.account[:urn]

        res << SAMANT::Uxv.find(:all, :conditions => {:hasSliceID => authorizer.account[:urn]})
      end
      res.flatten!
      res.map do |r|
        # Check for Interfaces & Sensors & Locations (Used in Rspec)
        snr << r.hasSensorSystem
        ifr << r.hasInterface
        lct << r.where
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
          r
        rescue InsufficientPrivilegesException
          nil
        end
      end
      ifr.flatten!
      #debug "@@@@@Interfaces: " + ifr.inspect
      #debug "@@@@@Sensors: " + snr.inspect
      #debug "@@@@@Locations: " + lct.inspect
      res << ifr << lct
      res.flatten!
    end


    def find_all_samant_resources(category = nil, description)
      av_classes = SAMANT.constants.select {|c| SAMANT.const_get(c).is_a? Class}
      debug "Available Classes = " + av_classes.inspect
      resources = []
      if category.nil? || category.empty?
        av_classes.each do |av_class|
          resources << eval("SAMANT::#{av_class}").find(:all, :conditions => description)
        end
      else
        category.each do |cat_class|
          cat_class = cat_class.classify
          unless av_classes.include?(cat_class.to_sym)
            raise UnavailableResourceException.new "Unknown Resource Category '#{cat_class.inspect}'. Please choose one of the following '#{av_classes.inspect}'"
          end
          resources << eval("SAMANT::#{cat_class}").find(:all, :conditions => description)
        end
      end
      debug "returned resources: " + resources.inspect
      resources.flatten!
    end

    # Find all components
    #
    # @param [Hash] Properties used for filtering the components
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Array<Component>] The components requested
    #
    def find_all_components(comp_descr, authorizer) # san tin apo panw me diaforetiko orisma
      res = OMF::SFA::Model::Component.where(comp_descr) # filtrarismena ta components
      res.map do |r|
        begin
          raise InsufficientPrivilegesException unless authorizer.can_view_resource?(r)
          r
        rescue InsufficientPrivilegesException
          nil
        end
      end.compact
    end

    # Find or Create a resource. If an account is given in the resource description
    # a child resource is created. Otherwise a managed resource is created. 
    #
    # @param [Hash] Describing properties of the resource
    # @param [String] Type to create
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Resource] The resource requested
    # @raise [UnknownResourceException] if no resource can be created
    #
    def find_or_create_resource(resource_descr, resource_type, authorizer)
      debug "find_or_create_resource: resource '#{resource_descr.inspect}' type: '#{resource_type}'"
      unless resource_descr.is_a? Hash
        raise FormatException.new "Unknown resource description '#{resource_descr.inspect}'"
      end
      begin
        return find_resource(resource_descr, resource_type, authorizer)
      rescue UnknownResourceException
      end
      create_resource(resource_descr, resource_type, authorizer)
    end

    def find_or_create_samant_resource(resource_descr, resource_type, authorizer)
      debug "find_or_create_samant_resource: resource '#{resource_descr.inspect}' type: '#{resource_type}'"
      #unless resource_descr.is_a? Hash
      unless resource_descr.is_a? Hash
        raise FormatException.new "Unknown resource description '#{resource_descr.inspect}'. Please provide a GURN."
      end
      #raise OMF::SFA::AM::Rest::BadRequestException.new "CREATE RESOURCES NOT YET IMPLEMENTED"
      begin
        # praktika edw psaxnei gia komvous-paidia! Mono tote enas komvos exei assigned SliceId
        # dld edw psaxnei gia leased komvous
        return find_samant_resource(resource_descr, resource_type, authorizer)
      rescue UnknownResourceException
      end
      create_samant_resource(resource_descr, resource_type, authorizer)
    end

    # Create a resource. If an account is given in the resource description
    # a child resource is created. The parent resource should be already present and managed
    # This will provide a copy of the actual physical resource.
    # Otherwise a managed resource is created which belongs to the 'nil_account'
    #
    # @param [Hash] Describing properties of the requested resource
    # @param [String] Type to create
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Resource] The resource requested
    # @raise [UnknownResourceException] if no resource can be created
    #
    def create_resource(resource_descr, type_to_create, authorizer)
      raise InsufficientPrivilegesException unless authorizer.can_create_resource?(resource_descr, type_to_create)

      if resource_descr[:account_id].nil? # an den dinetai account kanto paidi tou admin account
        resource = eval("OMF::SFA::Model::#{type_to_create.classify}").create(resource_descr)
        resource = manage_resource(resource)
      else
        resource = @scheduler.create_child_resource(resource_descr, type_to_create) # ???
      end

      raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' cannot be created" unless resource
      resource
    end

    def create_samant_resource(resource_descr, resource_type, authorizer)
      debug "mpika stin create_samant_resource"

      raise InsufficientPrivilegesException unless authorizer.can_create_samant_resource?(resource_descr, resource_type)

      unless resource_descr[:hasSliceID]
        debug "eimai stin unless"
        resource = eval("SAMANT::#{resource_type}").for(resource_descr[:comp_id])
        resource.hasSliceID = _get_nil_account.urn
        resource.save!
        # TODO resource management
      else
        debug "eimai stin else"
        resource = @scheduler.create_samant_child_resource(resource_descr, resource_type) # ???
      end

      raise UnknownResourceException.new "Resource '#{resource_descr.inspect}' cannot be created" unless resource
      resource
        #raise OMF::SFA::AM::Rest::BadRequestException.new "create RESOURCES NOT YET IMPLEMENTED"
    end
      # Find or create a resource for an account. If it doesn't exist,
    # is already assigned to someone else, or cannot be created, throws +UnknownResourceException+.
    #
    # @param [Hash] describing properties of the requested resource
    # @param [String] Type to create if not already exist
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Resource] The resource requested
    # @raise [UnknownResourceException] if no matching resource can be found
    #
    def find_or_create_resource_for_account(resource_descr, type_to_create, authorizer)
      debug "find_or_create_resource_for_account: r_descr:'#{resource_descr}' type:'#{type_to_create}' authorizer:'#{authorizer.inspect}'"
      resource_descr[:account_id] = authorizer.account.id
      find_or_create_resource(resource_descr, type_to_create, authorizer)
    end

    def find_or_create_samant_resource_for_account(resource_descr, type_to_create, authorizer)
      #raise OMF::SFA::AM::Rest::BadRequestException.new "CREATE RESOURCES NOT YET IMPLEMENTED"
      debug "find_or_create_samant_resource_for_account: r_descr:'#{resource_descr}' type:'#{type_to_create}' authorizer:'#{authorizer.inspect}'"
      debug "slice id = " + authorizer.account.urn.inspect
      #debug "slice id = " + resource_descr[:urns].to_s
      #debug "MONO = " + resource_descr.to_s
      resource_descr[:hasSliceID] = authorizer.account.urn
      #resource_descr[:hasSliceID] = resource_descr[:urns]
      find_or_create_samant_resource(resource_descr, type_to_create, authorizer)
    end


    def create_resources_from_rspec(descr_el, clean_state, authorizer) # ??? paizei na min xrisimopoieitai
      debug "create_resources_from_rspec: descr_el: '#{descr_el}' clean_state: '#{clean_state}' authorizer: '#{authorizer}'"

      resources = descr_el.children.map do |child| # xml children
        n = OMF::SFA::Model::Component.create_from_rspec(child, resources, self)
        child.create_from_rspec(authorizer)
      end
    end

    # Release 'resource'.
    #
    # This implementation simply frees the resource record.
    #
    # @param [Resource] Resource to release
    # @param [Authorizer] Authorization context
    # @raise [InsufficientPrivilegesException] if the resource is not allowed to be released
    #
    def release_resource(resource, authorizer)
      debug "release_resource: '#{resource.inspect}'"
      raise InsufficientPrivilegesException unless authorizer.can_release_resource?(resource)
      @scheduler.release_resource(resource) # datamapper -> resource -> destroy
    end

    def release_samant_resource(resource, authorizer)
      debug "release_samant_resource: '#{resource.inspect}'"
      raise InsufficientPrivilegesException unless authorizer.can_release_samant_resource?(resource)
      @scheduler.release_samant_resource(resource)
    end

    # Release an array of resources.
    #
    # @param [Array<Resource>] Resources to release
    # @param [Authorizer] Authorization context
    def release_resources(resources, authorizer)
      resources.each do |r|
        release_resource(r, authorizer)
      end
    end

    def release_samant_resources(resources, authorizer)
      resources.each do |r|
        # release only samant uxvs
        release_samant_resource(r, authorizer) if ((r.kind_of?SAMANT::Uxv) || (r.kind_of? SAMANT::Lease))
      end
    end

    # This method finds all the components of the specific account and
    # detaches them.
    #
    # @param [Account] Account who owns the components
    # @param [Authorizer] Authorization context
    #
    def release_all_components_for_account(account, authorizer)
      components = find_all_components_for_account(account, authorizer)
      release_resources(components, authorizer)
    end


    # Update the resources described in +resource_el+. Any resource not already assigned to the
    # requesting account will be added. If +clean_state+ is true, the state of all described resources
    # is set to the state described with all other properties set to their default values. Any resources
    # not mentioned are released. Returns the list
    # of resources requested or throw an error if ANY of the requested resources isn't available.
    #
    # Find or create a resource. If it doesn't exist, is already assigned to
    # someone else, or cannot be created, throws +UnknownResourceException+.
    #
    # @param [Element] RSpec fragment describing resource and their properties
    # @param [Boolean] Set all properties not mentioned to their defaults
    # @param [Authorizer] Defines context for authorization decisions
    # @return [OResource] The resource requested
    # @raise [UnknownResourceException] if no matching resource can be found
    # @raise [FormatException] if RSpec elements are not known
    #
    # @note Throws exception if a contained resource doesn't exist, but will not roll back any
    # already performed modifications performed on other resources.
    #
    def update_resources_from_rspec(descr_el, clean_state, authorizer)
      debug "update_resources_from_rspec: descr_el:'#{descr_el}' clean_state:'#{clean_state}' authorizer:'#{authorizer}'"
      if !descr_el.nil? && descr_el.name.downcase == 'rspec'
        xsd_path = File.join(File.dirname(__FILE__), '../../../schema/rspec-v3', 'request.xsd')
        schema = Nokogiri::XML::Schema(File.open(xsd_path))

        #TODO: make sure we pass the schema validation
        #res = schema.validate(descr_el.document)
        #raise FormatException.new("RSpec format is not valid: '#{res}'") unless res.empty?

        unless descr_el.xpath('//ol:*', 'ol' => OL_NAMESPACE).empty?
          #TODO: make proper schemas and validate them
          #lease_xsd_path = File.join(File.dirname(__FILE__), '../../../schema/rspec-v3', 'request-reservation.xsd')
          #lease_rng_path = File.join(File.dirname(__FILE__), '../../../schema/rspec-v3', 'request-reservation.rng')
          #lease_schema = Nokogiri::XML::Schema(File.open(lease_xsd_path))
          #lease_schema = Nokogiri::XML::RelaxNG(File.open(lease_rng_path))

          #TODO: make sure we pass the schema validation
          #res = schema.validate(descr_el.document)
          #raise FormatException.new("RSpec format is not valid: '#{res}'") unless res.empty?
        end


        if descr_el.namespaces.values.include?(OL_NAMESPACE) #  OL_NAMESPACE = "http://nitlab.inf.uth.gr/schema/sfa/rspec/1"
          leases = descr_el.xpath('//ol:lease', 'ol' => OL_NAMESPACE)
          # leases = descr_el.xpath('/xmlns:rspec/ol:lease', 'ol' => OL_NAMESPACE, 'xmlns' => "http://www.geni.net/resources/rspec/3")
          leases = update_leases_from_rspec(leases, authorizer)
        else
          leases = {}
        end

        resources = leases.values # hash to array

        nodes = descr_el.xpath('//xmlns:node').collect do |el|
          #debug "create_resources_from_xml::EL: #{el.inspect}"
          if el.kind_of?(Nokogiri::XML::Element)
            # ignore any text elements
            #if el[:lease_name].nil?
            #  update_resource_from_rspec(el, nil, clean_state, authorizer)
            #else # This node has a lease
            #  lease = leases.find { |l| l[:name].eql?(el[:lease_name]) }
            #leases = el.xpath('child::ol:lease', 'ol' => OL_NAMESPACE)
            #leases = update_leases_from_rspec(leases, authorizer)
            update_resource_from_rspec(el, leases, clean_state, authorizer)
            #end
          end
        end.compact

        resources = resources.concat(nodes) #(prwta leases, meta nodes)

        # channel reservation
        channels = descr_el.xpath('/xmlns:rspec/ol:channel', 'ol' => OL_NAMESPACE, 'xmlns' => "http://www.geni.net/resources/rspec/3").collect do |el|
          update_resource_from_rspec(el, leases, clean_state, authorizer)
        end.compact

        resources = resources.concat(channels) # meta channels

        # if resources.include?(false) # a component failed to be leased because of scheduler lease_component returned false
        #   resources.delete(false)
        #   release_resources(resources, authorizer)
        #   raise UnavailableResourceException.new "One or more resources failed to be allocated"
        # end

        failed_resources = []
        resources.each do |res|
          failed_resources << res if res.kind_of? Hash
        end

        unless failed_resources.empty?
          resources.delete_if {|item| failed_resources.include?(item)}
          urns = []
          failed_resources.each do |fres|
            puts 
            release_resource(fres[:failed], authorizer)
            urns << fres[:failed].urn
          end
          release_resources(resources, authorizer)
          raise UnavailableResourceException.new "The resources with the following URNs: '#{urns.inspect}' failed to be allocated"
        end

        # TODO: release the unused leases. The leases we have created but we never managed
        # to attach them to a resource because the scheduler denied it.
        if clean_state
          # Now free any leases owned by this account but not contained in +leases+
          # all_leases = Set.new(leases.values)
          #leases = descr_el.xpath('//ol:lease', 'ol' => OL_NAMESPACE).collect do |l|
          #  update_leases_from_rspec(leases, authorizer)
          #end.compact

          # leases.each_value {|l| l.all_resources(all_leases)}
          all_leases = find_all_leases(authorizer.account, authorizer)
          leases_values = leases.values # ena hash pou dimiourgithike apo ta leases pou eginan update apo rspec, to array
          unused = all_leases.delete_if do |l| # Deletes every element of +self+ for which block evaluates to +true+.
            out = leases_values.select {|res| res.id == l.id} # ston out vale auta pou uparxoun sto lease_values
            !out.empty? # delete_if an den einai adeios o pinakas out pou proekupse (an uparxei estw ena diladi gia to opoio isxuei h isotita)
          end
          # unused = find_all_leases(authorizer.account, authorizer).to_set - all_leases
          unused.each do |u|
            release_lease(u, authorizer)
          end
          # Now free any resources owned by this account but not contained in +resources+
          # rspec_resources = Set.new(resources)
          # resources.each {|r| r.all_resources(rspec_resources)}
          all_components = find_all_components_for_account(authorizer.account, authorizer)
          unused = all_components.delete_if do |comp|
            out = resources.select {|res| res.id == comp.id}
            !out.empty?
          end

          release_resources(unused, authorizer)
        end
        return resources
      else
        raise FormatException.new "Unknown resources description root '#{descr_el}'"
      end
    end

    # !!!SAMANT PROJECT ADDITION!!!

    def update_samant_resources_from_rspec(descr_el, clean_state, authorizer)
      debug "SAMANT update_resources_from_rspec: descr_el:'#{descr_el}' clean_state:'#{clean_state}' authorizer:'#{authorizer}'"
      if !descr_el.nil?
        # Returns an array containing lease urns
        # lease_urns = descr_el[0].values[0][OL_SEMANTICNS].map{|lease| lease["value"]}.flatten #.first["value"]
        # descr_el.detect{|d| d.has_key?("http://open-multinet.info/ontology/omn-lifecycle#Request/urn:uuid:fe603127-6445-4120-aae8-1cf8bcba3e07")} # Returns the first nested hash
        # debug "is hash? " + leases.is_a?(Hash).to_s
        # leases2 = leases.values[0]
        # leases3 = leases2.has_key?(OL_SEMANTICNS)
        # leases3 = leases2[OL_SEMANTICNS].first
        # leases4 = leases3.detect{|d| d.has_key?("value")}
        # lease_urns =
        # debug "leases = " + lease_urns.inspect
        # leases = []
        # if (lease_urns != nil)  # Returns an array containing the respective leases
        # lease_urns.each {
        #   |lease_urn|
        #   leases << descr_el.detect{|element| element.has_key?(lease_urn)}
        # }
        # debug "Leases: " + leases.inspect
        if descr_el.key?(:leases)
          leases_el = descr_el[:leases]
          debug "EXEI Leases: " + leases_el.inspect
          leases = update_samant_leases_from_rspec(leases_el, authorizer)
        else
          debug "DEN EXEI EXEI EXEI Leases: "
          leases_el = []
          leases = []
        end
        debug "leases contain: " + leases.inspect
        # raise OMF::SFA::AM::UnavailableResourceException.new "BREAKPOINT"

        resources = leases

        nodes = []
        if descr_el.key?(:nodes)
          node_els = descr_el[:nodes]
          debug "The following UxVs found: " + node_els.inspect
          node_els.each { |node_el|
            nodes << update_samant_resource_from_rspec(node_el, resources, clean_state, authorizer) # at this stage resources == leases
          }
        else
          nodes
        end
        debug "Returned UxVs contain: " + nodes.compact.inspect # compact removes nil values
        resources = resources.concat(nodes.compact)
        debug "accumulated contain: " + resources.inspect
        # raise OMF::SFA::AM::UnavailableResourceException.new "BREAKPOINT"

        # node_urns = descr_el[(0].values[0][RES_SEMANTICNS].map{|res| res["value"]})
        # nodes = []
        # raise OMF::SFA::AM::Rest::BadRequestException.new "breakpoint"
        # if (node_urns != nil)
        #  node_els = []
        #  node_urns.each {
        #    |node_urn|
        #    node_els << descr_el.detect{|element| element.has_key?(node_urn)}
        #  }
        #  node_els.each {
        #    |node_el|
        #    nodes << update_samant_resource_from_rspec(node_el, leases, clean_state, authorizer)
        #  }
        #else
        #  nodes = []
        #end

        failed_resources = []
        resources.each do |res|
          failed_resources << res if res.kind_of? Hash # ta failarismena einai { failed => resource }
        end

        debug "failed resources = " + failed_resources.inspect

        unless failed_resources.empty?
          # delete_if - delete elements that don't match from current array and return the array
          resources.delete_if {|item|
            debug "checking resource for failed: " + item.inspect
            failed_resources.include?(item)
          }
          # debug "New Resources = " + resources.inspect
          urns = []
          failed_resources.each do |fres|
            # puts
            release_samant_resource(fres[:failed], authorizer)
            urns << fres[:failed].hasParent.to_uri.to_s
          end
          # TODO 1.check an prepei na gyrisw nil, 2.prepei na kanw raise to unavailable exception?
          #  Allocate is an all or nothing request: if the aggregate cannot completely satisfy the request RSpec, it should fail the request entirely.
          release_samant_resources(resources, authorizer)
          #return resources
          raise UnavailableResourceException.new "The resources with the following URNs: '#{urns.inspect}' failed to be allocated. Request dropped."
        end


        # Now free any leases owned by this account but not contained in +leases+
        if clean_state
          all_leases = find_all_samant_leases(authorizer.account.urn, authorizer) # array
          debug "all leases = " + all_leases.inspect
          unused = all_leases.delete_if do |l|
            out = leases.select {|res| res.uri == l.uri}
            !out.empty?
          end
          debug "unused leases: " + unused.inspect
          unused.each do |u|
            release_samant_lease(u, authorizer)
          end

          # Now free any resources owned by this account but not contained in +resources+
          all_components = find_all_samant_components_for_account(authorizer.account.urn, authorizer)
          unused = all_components.delete_if do |comp|
            out = resources.select {|res| res.uri == comp.uri}
            !out.empty?
          end
          release_samant_resources(unused, authorizer)
        end
        return resources
      else
        raise FormatException.new "Unknown resources description root '#{descr_el}'"
      end

      # raise OMF::SFA::AM::Rest::BadRequestException.new "UPDATE RESOURCES NOT YET IMPLEMENTED"
    end

    # Update a single resource described in +resource_el+. The respective account is
    # extracted from +opts+. Any mentioned resources not already available to the requesting account
    # will be created. If +clean_state+ is set to true, all state of a resource not specifically described
    # will be reset to it's default value. Returns the resource updated.
    #
    def update_resource_from_rspec(resource_el, leases, clean_state, authorizer) # channels kai nodes, oxi leases
      if uuid_attr = (resource_el.attributes['uuid'] || resource_el.attributes['id'])
        uuid = UUIDTools::UUID.parse(uuid_attr.value)
        resource = find_resource({:uuid => uuid}, authorizer) # wouldn't know what to create
      elsif comp_id_attr = resource_el.attributes['component_id']
        comp_id = comp_id_attr.value
        comp_gurn = OMF::SFA::Model::GURN.parse(comp_id) # get rid of "urn:publicid:IDN"
        #if uuid = comp_gurn.uuid
        #  resource_descr = {:uuid => uuid}
        #else
        #  resource_descr = {:name => comp_gurn.short_name}
        #end
        resource_descr = {:urn => comp_gurn.to_s}
        resource = find_or_create_resource_for_account(resource_descr, comp_gurn.type, authorizer)
        unless resource
          raise UnknownResourceException.new "Resource '#{resource_el.to_s}' is not available or doesn't exist"
        end
      elsif name_attr = resource_el.attributes['component_name']
        # the only resource we can find by a name attribute is a group
        # TODO: Not sure about the 'group' assumption
        name = name_attr.value
        resource = find_or_create_resource_for_account({:name => name}, 'unknown', {}, authorizer)
      else
        raise FormatException.new "Unknown resource description '#{resource_el.attributes.inspect}"
      end

      resource.client_id = resource_el['client_id']
      resource.save

      leases_el = resource_el.xpath('child::ol:lease_ref|child::ol:lease', 'ol' => OL_NAMESPACE)
      leases_el.each do |lease_el|
        #TODO: provide the scheduler with the resource and the lease to attach them according to its policy.
        # if the scheduler refuses to attach the lease to the resource, we should release both of them.
        # start by catching the exceptions of @scheduler
        lease_id = lease_el['id_ref'] || lease_el['client_id']
        lease = leases[lease_id]

        unless lease.nil? || lease.components.include?(resource) # lease.components.first(:uuid => resource.uuid)
          return {failed: resource} unless @scheduler.lease_component(lease, resource) 

          monitoring_el = resource_el.xpath('//xmlns:monitoring')
          unless monitoring_el.empty?
            oml_url = monitoring_el.first.xpath('//xmlns:oml_server').first['url']
            @liaison.start_resource_monitoring(resource, lease, oml_url)
          end
        end
      end

      # if resource.group?
      #   members = resource_el.children.collect do |el|
      #     if el.kind_of?(Nokogiri::XML::Element)
      #       # ignore any text elements
      #       update_resource_from_rspec(el, clean_state, authorizer)
      #     end
      #   end.compact
      #   debug "update_resource_from_rspec: Creating members '#{members}' for group '#{resource}'"

      #   if clean_state
      #     resource.members = members
      #   else
      #     resource.add_members(members)
      #   end
      # else
      #   if clean_state
      #     # Set state to what's described in +resource_el+ ONLY
      #     resource.create_from_xml(resource_el, authorizer)
      #   else
      #     resource.update_from_xml(resource_el, authorizer)
      #   end
      # end
      sliver_type_el = resource_el.xpath('//xmlns:sliver_type')
      unless sliver_type_el.empty?
        sliver_type = OMF::SFA::Model::SliverType.first({name: sliver_type_el.first['name']})
        resource.sliver_type = sliver_type # models -> node
      end

      resource.save
      resource

    rescue UnknownResourceException
      error "Ignoring Unknown Resource: #{resource_el}"
      nil
    end

    def update_samant_resource_from_rspec(resource_el, leases, clean_state, authorizer)
      debug "Resource Element = " + resource_el.inspect
      resource_descr = {}
      # resource_el = resource_el.values[0]
      # Search chain: uuid/id -> component_id -> component_name, (uuid rarely/never used though)
      if uuid_attr = (resource_el[:uuid] || resource_el[:id]) # rarely used probably cut out
        debug "UUID exists: " + uuid_attr.inspect
        #resource = find_resource({:uuid => uuid}, authorizer)
      elsif comp_id = resource_el[:component_id]
        comp_gurn = OMF::SFA::Model::GURN.parse(comp_id)
        classtype = comp_gurn.type.to_s.upcase
        # TODO reconsider plain string as range for hasComponentID
        resource_descr[:hasComponentID] = Spira::Types::AnyURI.serialize(comp_gurn.to_s)
        # resource_descr[:hasUxVType] = comp_gurn.type.to_s.upcase # TODO use when triplestore populated accordingly
        debug "classtype = " + classtype
        resource = find_or_create_samant_resource_for_account(resource_descr, classtype, authorizer)
        unless resource
          raise UnknownResourceException.new "Resource '#{resource_el.to_s}' is not available or doesn't exist"
        end
      elsif comp_name = resource_el[:component_name]
        resource_descr = {:hasComponentName => comp_name}
        resource = find_or_create_samant_resource_for_account(resource_descr, nil, authorizer)
      else
        raise FormatException.new "Unknown resource description"
      end

      #if comp_id_attr = resource_el[OMNcomponentID]
        # debug "YPARXEI COMPONENT ID"
        # prev # resource_descr = {:hasComponentID => RDF::URI.new(comp_id_attr.first["value"])}
      #  resource_descr = {:resourceId => comp_id_attr.first["value"]}
      #  comp_type = resource_el[W3type].first["value"].split('#')[1]
      #  debug "Component URN + Type = " + resource_descr.inspect + " + " + comp_type
      #  resource = find_or_create_samant_resource_for_account(resource_descr, comp_type, authorizer)
      #  #resource = nil
      #  unless resource
      #    raise UnknownResourceException.new "Resource '#{resource_el[W3label].first["value"]}' is not available or doesn't exist"
      #  end
      #elsif name_attr = resource_el[OMNcomponentName]
        # debug "YPARXEI NAME"
      #  resource_descr = {:hasComponentName => name_attr.first["value"]}
      #  resource = find_or_create_samant_resource_for_account(resource_descr, comp_type, authorizer)
      #else
      #  raise FormatException.new "Unknown resource description"
      #end

      debug "EINAI TO PAIDI? " + resource.uri.to_s # NAI EINAI
      # debug "IDIDIDIDIDID " + resource_el[OMNID].inspect
      # prev # resource.hasID = resource_el[OMNID]
      # resource.resourceId = resource_el[OMNID].first["value"]
      # resource.resourceId = resource.hasParent.resourceId
      # debug "Child resource id vs parent resource id = " + resource.resourceId.to_s + " vs " + resource.hasParent.resourceId.to_s
      # resource.save!
      #TODO edw kapou prepei na kanoume assign to client id sto child

      lease_id = resource_el[:lease_ref]
      debug "lease ref = " + lease_id
      lease = leases.select {|lease| lease.clientID == lease_id}.first
      #lease = leases.first
      debug "Lease selected = " + lease.inspect
      unless lease.nil?
        return {failed: resource} unless @scheduler.lease_samant_component(lease, resource)
        #TODO na dw an xreiazetai na kanw kati me monitoring kai liaison
      end

      # TODO something about sliver types

      resource.save
      resource

    rescue UnknownResourceException
      error "Ignoring Unknown Resource: #{resource_el}"
      nil
    end

    # Update the leases described in +leases+. Any lease not already assigned to the
    # requesting account will be added. If +clean_state+ is true, the state of all described leases
    # is set to the state described with all other properties set to their default values. Any leases
    # not mentioned are canceled. Returns the list
    # of leases requested or throw an error if ANY of the requested leases isn't available.
    #
    # @param [Element] RSpec fragment describing leases and their properties
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Hash{String => Lease}] The leases requested
    # @raise [UnknownResourceException] if no matching lease can be found
    # @raise [FormatException] if RSpec elements are not known
    #
    def update_leases_from_rspec(leases, authorizer)
      debug "update_leases_from_rspec: leases:'#{leases.inspect}' authorizer:'#{authorizer.inspect}'"
      leases_hash = {}
      unless leases.empty?
        leases.each do |lease|
          l = update_lease_from_rspec(lease, authorizer)
          leases_hash.merge!(l)
        end
      end
      leases_hash
    end

    def update_samant_leases_from_rspec(leases, authorizer)
      debug "update_samant_leases_from_rspec: leases:'#{leases.inspect}' authorizer:'#{authorizer.inspect}'"
      leases_arry = []
      unless leases.empty?
        leases.each do |lease|
          l = update_samant_lease_from_rspec(lease, authorizer)
          leases_arry << l
        end
      end
      debug "leases array: " + leases_arry.inspect
      leases_arry
    end

    # Create or Modify leases through RSpecs
    #
    # When a UUID is provided, then the corresponding lease is modified. Otherwise a new
    # lease is created with the properties described in the RSpecs.
    #
    # @param [Nokogiri::XML::Node] RSpec fragment describing lease and its properties
    # @param [Authorizer] Defines context for authorization decisions
    # @return [Lease] The requested lease
    # @raise [UnavailableResourceException] if no matching resource can be found or created
    # @raise [FormatException] if RSpec elements are not known
    #
    def update_lease_from_rspec(lease_el, authorizer)

      if (lease_el[:valid_from].nil? || lease_el[:valid_until].nil?)
        raise UnavailablePropertiesException.new "Cannot create lease without ':valid_from' and 'valid_until' properties"
      end

      lease_properties = {:valid_from => Time.parse(lease_el[:valid_from]).utc, :valid_until => Time.parse(lease_el[:valid_until]).utc}

      begin # an uparxei
        raise UnavailableResourceException unless UUID.validate(lease_el[:id]) # mporei na min yparxei kan to lease id (synithws den yparxei)
        lease = find_lease({:uuid => lease_el[:id]}, authorizer) # vres to me uuid
        if lease.valid_from != lease_properties[:valid_from] || lease.valid_until != lease_properties[:valid_until] # update sti diarkeia
          lease = modify_lease(lease_properties, lease, authorizer)
          return { lease_el[:id] => lease }
        else
          return { lease_el[:id] => lease }
        end
      rescue UnavailableResourceException # an den uparxei, ftiaxto
        lease_descr = {account_id: authorizer.account.id, valid_from: lease_el[:valid_from], valid_until: lease_el[:valid_until]}
        lease = find_or_create_lease(lease_descr, authorizer)
        lease.client_id = lease_el[:client_id]
        lease.save
        return { (lease_el[:client_id] || lease_el[:id]) => lease }
      end
    end

    def update_samant_lease_from_rspec(lease_el, authorizer)
      # lease_urn = lease_el.keys[0].dup
      # lease_id.slice! OMNlease
      # lease_el = lease_el.values[0]
      # raise OMF::SFA::AM::UnavailableResourceException.new 'BREAKPOINT'
      # debug "Lease urn: " + lease_urn
      # debug "Lease (contains) properties: " + lease_el.inspect
      # debug "Hash keys: " + lease_el.keys.inspect

      # if (!lease_el.has_key?(OMNstartTime) || !lease_el.has_key?(OMNexpirationTime))
      #   raise UnavailablePropertiesException.new "Cannot create lease without 'startTime' and 'expirationTime' properties"
      # end

      if (lease_el[:valid_from].nil? || lease_el[:valid_until].nil?)
        raise UnavailablePropertiesException.new "Cannot create lease without ':valid_from' and 'valid_until' properties"
      end

      lease_properties = {:startTime => Time.parse(lease_el[:valid_from]).utc, :expirationTime => Time.parse(lease_el[:valid_until]).utc}
      debug "Lease time properties: " + lease_properties.inspect

      begin
        raise UnavailableResourceException unless UUID.validate(lease_el[:id])
        lease = find_samant_lease(lease_el[:id], authorizer)
        if lease.startTime != lease_properties[:startTime] || lease.expirationTime != lease_properties[:expirationTime]
          debug "found with different properties!"
          lease = modify_samant_lease(lease_properties, lease, authorizer)
          return lease # or { lease_urn => lease }
        else
          debug "found with same properties!"
          return lease # or { lease_urn => lease }
        end

      rescue UnavailableResourceException
        lease_uuid = SecureRandom.uuid
        lease_descr = {:hasSliceID => authorizer.account[:urn], :startTime => Time.parse(lease_el[:valid_from]), :expirationTime => Time.parse(lease_el[:valid_until]), :hasID => lease_uuid, :clientID => lease_el[:client_id]}
        debug "Lease Doesn't Exist. Create with Descr: " + lease_descr.inspect + " uuid: " + lease_uuid.inspect
        #raise OMF::SFA::AM::UnavailableResourceException.new 'BREAKPOINT'
        lease = find_or_create_samant_lease(lease_uuid, lease_descr, authorizer)
        # lease.client_id = lease_el[:client_id] # TODO currently not modelled
        # lease.save
        return lease #{lease_urn => lease} # TODO clarification on hash return, theloume kati me tripletes
        # raise OMF::SFA::AM::Rest::BadRequestException.new "UPDATE LEASES NOT YET IMPLEMENTED"
      end
    end

    def renew_samant_lease(lease, leased_components, authorizer, new_expiration_time)
      debug "Checking Lease (prior): " + lease.expirationTime.inspect
      unless new_expiration_time > lease.expirationTime
        raise OMF::SFA::AM::UnavailableResourceException.new "New Expiration Time cannot be prior to former Expiration Time."
      end
      old_lease_properties = {:startTime => lease.startTime, :expirationTime => lease.expirationTime}
      new_lease_properties = {:startTime => lease.startTime, :expirationTime => new_expiration_time}
      # check only during the difference
      lease.startTime = lease.expirationTime + 1.second
      lease.expirationTime = new_expiration_time
      debug "Checking Lease (updated): from " + lease.startTime.inspect + " to " + lease.expirationTime.inspect
      renewal_success = true
      leased_components.each do |component|
        unless @scheduler.lease_samant_component(lease, component)
          debug "One Fail!"
          renewal_success = false
          break
        end
      end
      debug "Checking Lease (updated): " + lease.expirationTime.inspect
      unless renewal_success
        modify_samant_lease(old_lease_properties, lease, authorizer)
        debug "Checking Lease (cancelling): " + lease.expirationTime.inspect
        raise OMF::SFA::AM::UnavailableResourceException.new "Could not renew sliver due to unavailability of resources during that time."
      end
      modify_samant_lease(new_lease_properties, lease, authorizer) # also updates the event scheduler
    end

  end # class
end # OMF::SFA::AM
