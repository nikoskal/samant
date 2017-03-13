require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
#require_relative '../../omn-models/populator.rb'
#require 'data_objects'
#require 'rdf/do'
#require 'do_sqlite3'
#$repository = Spira.repository = RDF::DataObjects::Repository.new uri: "sqlite3:./test.db"
#require_relative '../../samant_models/sensor.rb'
#require_relative '../../samant_models/uxv.rb'

module OMF::SFA::AM::Rest

  # Assume PENDING = pending, ALLOCATED = accepted, PROVISIONED = active, RPC compatibility mappings
  $acceptable_lease_states = [SAMANT::ALLOCATED, SAMANT::PROVISIONED, SAMANT::PENDING]

  class SamantHandler < RestHandler

    def find_handler(path, opts)
      debug "!!!SAMANT handler!!!"
      RDF::Util::Logger.logger.parent.level = 'off' # Worst Bug *EVER*
      # debug "PATH = " + path.inspect
      # Define method called
      if path.map(&:downcase).include? "getversion"
        opts[:resource_uri] = :getversion
      elsif path.map(&:downcase).include? "listresources"
        opts[:resource_uri] = :listresources
      elsif path.map(&:downcase).include? "describe"
        opts[:resource_uri] = :describe
      elsif path.map(&:downcase).include? "status"
        opts[:resource_uri] = :status
      elsif path.map(&:downcase).include? "allocate"
        opts[:resource_uri] = :allocate
      elsif path.map(&:downcase).include? "renew"
        opts[:resource_uri] = :renew
      elsif path.map(&:downcase).include? "provision"
        opts[:resource_uri] = :provision
      elsif path.map(&:downcase).include? "delete"
        opts[:resource_uri] = :delete
      elsif path.map(&:downcase).include? "shutdown"
        opts[:resource_uri] = :shutdown
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
      return self
    end

    # GET:
    #
    # @param method used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_get (method, options)
      if method == :getversion
        get_version
      elsif method == :listresources
        list_resources(options)
      elsif method == :describe
        d_scribe(options)
      elsif method == :status
        status(options)
      end
    end

    # POST:
    #
    # @param function used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_post (method, options)
      if method == :allocate
        allocate(options)
      elsif method == :provision
        provision(options)
      end
    end

    def on_put(method,options)
      if method == :renew
        renew(options)
      end
    end

    def on_delete (method, options)
      if method == :delete
        delete(options)
      elsif method == :shutdown
        shutdown(options)
      end
    end

    # GetVersion:
    # Return the version of the GENI Aggregate API
    # supported by this aggregate.

    def get_version()
      # TODO Nothing implemented yet for GetVersion call
      raise OMF::SFA::AM::Rest::BadRequestException.new "getversion NOT YET IMPLEMENTED"
    end

    # ListResources:
    # Return information about available resources
    # or resources allocated to a slice.

    def list_resources(options)
      #debug "options = " + options.inspect
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect

      debug 'ListResources: Options: ', params.inspect

      only_available = params[:only_available]
      compressed = params[:geni_compressed] # TODO Nothing implemented yet for REST API compression
      slice_urn = params[:slice_urn]
      rspec_version = params[:geni_rspec_version] # TODO Nothing implemented yet for REST API rspec_version

      authorizer = options[:req].session[:authorizer]
      #debug "!!!USER = " + authorizer.user.inspect
      #debug "!!!ACCOUNT = " + authorizer.account.inspect
      #debug "!!!ACCOUNT_URN = " + authorizer.account[:urn]
      #debug "!!!ACCOUNT = " + authorizer.user.accounts.first.inspect

      if slice_urn
        @return_struct[:code][:geni_code] = 4 # Bad Version
        @return_struct[:output] = "Geni version 3 no longer supports arguement 'geni_slice_urn' for list resources method, please use describe instead."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      else
        resources = @am_manager.find_all_samant_leases(nil, $acceptable_lease_states, authorizer)
        comps = @am_manager.find_all_samant_components_for_account(nil, authorizer)
        # child nodes should not be included in listresources
        comps.delete_if {|c| c.to_uri.to_s.include?"/leased"}
        if only_available
          debug "only_available selected"
          # TODO maybe delete also interfaces and locations as well
          comps.delete_if {|c| (c.kind_of?SAMANT::Uxv) && c.hasResourceStatus && (c.hasResourceStatus.to_uri == SAMANT::BOOKED.to_uri) }
        end
        resources.concat(comps)
        #debug "the resources: " + resources.inspect
        used_for_side_effect = OMF::SFA::AM::Rest::ResourceHandler.rspecker(resources) # -> creates the advertisement rspec file inside /ready4translation (less detailed, sfa enabled)
        res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options) # -> returns the json formatted results (more detailed, omn enriched)
        # TODO insert identifier to res so to distinguish advertisement from request from manifest etc. (see also am_rpc_service)
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = res
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::InsufficientPrivilegesException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Describe:
    # Return information about resources allocated to a slice.

    def d_scribe(options)
      # Request info regarding either *one* slice or *many* slivers belonging to *one_slice*
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect
      urns = params[:urns]
      debug 'Describe: URNS: ', urns.inspect, ' Options: ', params.inspect

      if urns.nil? || urns.empty?
        @return_struct[:code][:geni_code] = 1 # Bad Arguments
        @return_struct[:output] = "Argument 'urns' is either empty or nil."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      compressed = params["geni_compressed"] # TODO Nothing implemented yet for REST API compression
      rspec_version = params["geni_rspec_version"] # TODO Nothing implemented yet for REST API rspec_version

      # SLICE == ACCOUNT / SLIVER == LEASE
      # Must provide full slice URN, e.g /urn:publicid:IDN+omf:netmode+account+__default__
      slice_urn, slivers_only, error_code, error_msg = parse_samant_urns(urns)
      if error_code != 0
        @return_struct[:code][:geni_code] = error_code
        @return_struct[:output] = error_msg
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      authorizer = options[:req].session[:authorizer]

      resources = []
      leases = []
      if slivers_only
        urns.each do |urn|
          l = @am_manager.find_samant_lease(urn, authorizer) # TODO maybe check thoroughly if slice_urn of slivers is the same as the authenticated user's
          resources << l
          leases << l
          l.isReservationOf.each do |comp|
            resources << comp if comp.hasSliceID == authorizer.account[:urn]
          end
        end
      else
        resources = @am_manager.find_all_samant_leases(slice_urn, $acceptable_lease_states, authorizer)
        leases = resources.dup
        resources.concat(@am_manager.find_all_samant_components_for_account(slice_urn, authorizer))
      end

      used_for_side_effect = OMF::SFA::AM::Rest::ResourceHandler.rspecker(resources) # -> creates the advertisement rspec file inside /ready4translation (less detailed, sfa enabled)
      res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options) # -> returns the json formatted results (more detailed, omn enriched)

      value = {}
      value[:omn_rspec] = res # was :geni_rspec
      value[:geni_urn] = slice_urn
      value[:geni_slivers] = []
      leases.each do |lease|
        tmp = {}
        tmp[:geni_sliver_urn]         = lease.to_uri.to_s
        tmp[:geni_expires]            = lease.expirationTime.to_s
        #debug "Reservation Status vs SAMANT::ALLOCATED: " + lease.hasReservationState.uri + " vs " + SAMANT::ALLOCATED.uri
        tmp[:geni_allocation_status]  = if lease.hasReservationState.uri == SAMANT::ALLOCATED.uri then "geni_allocated"
                                        elsif lease.hasReservationState == SAMANT::PROVISIONED then "geni_provisioned"
                                        else "geni_unallocated"
                                        end
        tmp[:geni_operational_status] = "NO_INFO" # lease.isReservationOf.hasResourceStatus.to_s # TODO Match geni_operational_status with an ontology concept
        value[:geni_slivers] << tmp
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = value
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::InsufficientPrivilegesException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Allocate:
    # Allocate resources as described in a request RSpec argument to a slice with the
    # named URN. On success, one or more slivers are allocated, containing resources
    # satisfying the request, and assigned to the given slice. Allocated slivers are
    # held for an aggregate-determined period.

    def allocate(options)
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect
      urns = params[:urns]
      rspec = body[:rspec]

      debug 'Allocate: URNs: ', urns, ' RSPEC: ', rspec, ' Options: ', params.inspect, "time: ", Time.now

      if urns.nil?
        @return_struct[:code][:geni_code] = 1 # Bad Arguments
        @return_struct[:output] = "The following arguments is missing: 'urns'"
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      if urns.kind_of? String
        tmp = urns
        urns = []
        urns << tmp
      end

      slice_urn, slivers_only, error_code, error_msg = parse_samant_urns(urns)
      if error_code != 0
        @return_struct[:code][:geni_code] = error_code
        @return_struct[:output] = error_msg
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      authorizer = options[:req].session[:authorizer]

      #debug "is hash? " + rspec.is_a?(Hash).to_s
      #debug "PARSED RSPEC = " + rspec.inspect
      #resources = @am_manager.update_samant_resources_from_rspec(rspec, true, authorizer)
      #debug "returned resources = " + resources.inspect
      #raise OMF::SFA::AM::UnavailableResourceException.new "BREAKPOINT"

      resources = @am_manager.update_samant_resources_from_rspec(rspec, true, authorizer)
      debug "returned resources = " + resources.inspect

        #resources.pop #removes last element of array
      leases_only = true
      resources.each do |res|
        if !res.kind_of? SAMANT::Lease
          #debug "what am i looking? " + res.inspect
          #debug "is a lease? "
          leases_only = false
          break
        end
      end
      debug "Leases only? " + leases_only.to_s

      if resources.nil? || resources.empty? || leases_only
        debug('CreateSliver failed', ":all the requested resources were unavailable for the requested DateTime.")

        resources.each do |res|
          # TODO logika to check tou PENDING xreiazetai stin periptwsi kata tin opoia to lease proupirxe
          @am_manager.get_scheduler.delete_samant_lease(res) # if res.hasReservationState == SAMANT::PENDING
        end

        @return_struct[:code][:geni_code] = 7 # operation refused
        @return_struct[:output] = "all the requested resources were unavailable for the requested DateTime."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      used_for_side_effect = OMF::SFA::AM::Rest::ResourceHandler.rspecker(resources) # -> creates the advertisement rspec file inside /ready4translation (less detailed, sfa enabled)
      res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options) # -> returns the json formatted results (more detailed, omn enriched)

      value = {}
      value[:geni_rspec] = res
      value[:geni_slivers] = []
      resources.each do |r|
        if r.is_a? SAMANT::Lease
          tmp = {}
          tmp[:geni_sliver_urn]         = r.to_uri.to_s
          tmp[:geni_expires]            = r.expirationTime.to_s
          #debug "Reservation Status vs SAMANT::ALLOCATED: " + lease.hasReservationState.uri + " vs " + SAMANT::ALLOCATED.uri
          tmp[:geni_allocation_status]  = if r.hasReservationState.uri == SAMANT::ALLOCATED.uri then "geni_allocated"
                                          else "geni_unallocated"
                                          end
          value[:geni_slivers] << tmp
        end
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = value
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::InsufficientPrivilegesException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::UnknownResourceException => e
      debug('CreateSliver Exception', e.to_s)
      @return_struct[:code][:geni_code] = 12 # Search Failed
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::FormatException => e
      debug('CreateSliver Exception', e.to_s)
      @return_struct[:code][:geni_code] = 4 # Bad Version
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::UnavailableResourceException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Provision:
    # Request that the named geni_allocated slivers be made geni_provisioned,
    # instantiating or otherwise realizing the resources, such that they have
    # a valid geni_operational_status and may possibly be made geni_ready for
    # experimenter use. This operation is synchronous, but may start a longer process.

    def provision(options)
      # TODO Nothing implemented yet for Provision call
      raise OMF::SFA::AM::Rest::BadRequestException.new "Provision NOT YET IMPLEMENTED"
    end

    # Renew:
    # Request that the named slivers be renewed, with their expiration
    # extended. If possible, the aggregate should extend the slivers to
    # the requested expiration time, or to a sooner time if policy limits
    # apply. This method applies to slivers that are geni_allocated or to
    # slivers that are geni_provisioned, though different policies may apply
    # to slivers in the different states, resulting in much shorter max
    # expiration times for geni_allocated slivers.

    def renew(options)
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect
      urns = params[:urns]
      expiration_time = params[:expiration_time]

      debug('Renew: URNs: ', urns.inspect, ' until <', expiration_time, '>')

      if urns.nil? || urns.empty? || expiration_time.nil?
        @return_struct[:code][:geni_code] = 1 # Bad Arguments
        @return_struct[:output] = "Some of the following arguments are missing: 'slice_urn', 'expiration_time'"
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      expiration_time = Time.parse(expiration_time).utc

      slice_urn, slivers_only, error_code, error_msg = parse_samant_urns(urns)
      if error_code != 0
        @return_struct[:code][:geni_code] = error_code
        @return_struct[:output] = error_msg
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      debug('Renew ', slice_urn, ' until <', expiration_time, '>')

      authorizer = options[:req].session[:authorizer]

      leases = []
      if slivers_only
        urns.each do |urn|
          l = @am_manager.find_samant_lease(urn, authorizer) # TODO maybe check thoroughly if slice_urn of slivers is the same as the authenticated user's
          leases << l
        end
      else
        leases = @am_manager.find_all_samant_leases(slice_urn, $acceptable_lease_states, authorizer)
      end
      debug "Leases contain: " + leases.inspect

      if leases.nil? || leases.empty?
        @return_struct[:code][:geni_code] = 1 # Bad Arguments
        @return_struct[:output] = "There are no slivers for slice: '#{slice_urn}'."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      # TODO currently only one lease renewal supported
      leased_components = @am_manager.find_all_samant_components_for_account(slice_urn, authorizer)
      leased_components.delete_if {|c| !c.to_uri.to_s.include?"/leased"} # TODO FIX must return only child uxv nodes
      debug "Leased Components: " + leased_components.inspect

      # TODO: check account/slice renew concept. Is it necessary?

      value = {}
      value[:geni_urn] = slice_urn
      value[:geni_slivers] = []
      leases.each do |lease|
        @am_manager.renew_samant_lease(lease, leased_components, authorizer, expiration_time)
        tmp = {}
        tmp[:geni_sliver_urn]         = lease.to_uri.to_s
        tmp[:geni_expires]            = lease.expirationTime.to_s
        tmp[:geni_allocation_status]  = if lease.hasReservationState.uri == SAMANT::ALLOCATED.uri then "geni_allocated"
                                        elsif lease.hasReservationState == SAMANT::PROVISIONED then "geni_provisioned"
                                        else "geni_unallocated"
                                        end
        tmp[:geni_operational_status] = "NO_INFO" # lease.isReservationOf.hasResourceStatus.to_s # TODO Match geni_operational_status with an ontology concept
        value[:geni_slivers] << tmp
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = value
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::UnavailableResourceException => e
      @return_struct[:code][:geni_code] = 12 # Search Failed
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::InsufficientPrivilegesException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Status:
    # Get the status of a sliver or slivers belonging to
    # a single slice at the given aggregate.

    def status(options)
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect
      urns = params[:urns]
      debug('Status for ', urns.inspect, ' OPTIONS: ', params.inspect)

      if urns.nil?
        @return_struct[:code][:geni_code] = 1 # Bad Arguments
        @return_struct[:output] = "The following argument is missing: 'slice_urn'"
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      slice_urn, slivers_only, error_code, error_msg = parse_samant_urns(urns)
      if error_code != 0
        @return_struct[:code][:geni_code] = error_code
        @return_struct[:output] = error_msg
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      authorizer = options[:req].session[:authorizer]

      leases = []
      if slivers_only
        urns.each do |urn|
          l = @am_manager.find_samant_lease(urn, authorizer)
          leases << l
        end
      else
        leases =  @am_manager.find_all_samant_leases(slice_urn, [SAMANT::ALLOCATED, SAMANT::PROVISIONED], authorizer)
      end

      value = {}
      value[:geni_urn] = slice_urn
      value[:geni_slivers] = []
      leases.each do |lease|
        tmp = {}
        tmp[:geni_sliver_urn]         = lease.to_uri.to_s
        tmp[:geni_expires]            = lease.expirationTime.to_s
        tmp[:geni_allocation_status]  = if lease.hasReservationState.uri == SAMANT::ALLOCATED.uri then "geni_allocated"
                                        else "geni_provisioned"
                                        end
        tmp[:geni_operational_status] = "NO INFO"
        value[:geni_slivers] << tmp
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = value
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::InsufficientPrivilegesException => e
      @return_struct[:code][:geni_code] = 3
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Delete a sliver by stopping it if it is still running, and then
    # deallocating the resources associated with it. This call will
    # stop and deallocate all resources associated with the given
    # slice URN.
    # (close the account and release the attached resources)

    def delete(options)
      body, format = parse_body(options)
      params = body[:options]
      #debug "Body & Format = ", opts.inspect + ", " + format.inspect
      urns = params[:urns]
      debug('DeleteSliver: URNS: ', urns.inspect, ' Options: ', options.inspect)

      slice_urn, slivers_only, error_code, error_msg = parse_samant_urns(urns)
      if error_code != 0
        @return_struct[:code][:geni_code] = error_code
        @return_struct[:output] = error_msg
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      authorizer = options[:req].session[:authorizer]

      value = []
      if slivers_only # NOT SURE IF EVER APPLIED
        urns.each do |urn|
          l = @am_manager.find_samant_lease(urn, authorizer)
          tmp = {}
          tmp[:geni_sliver_urn] = urn
          tmp[:geni_allocation_status] = 'geni_unallocated'
          tmp[:geni_expires] = l.expirationTime.to_s
          value << tmp
        end
      else
        # TODO FIND ACCOUNT
        leases = @am_manager.find_all_samant_leases(slice_urn, [SAMANT::ALLOCATED, SAMANT::PROVISIONED], authorizer)
        debug "leases = " + leases.inspect
        if leases.nil? || leases.empty?
          @return_struct[:code][:geni_code] = 1 # Bad Arguments
          @return_struct[:output] = "There are no slivers for slice: '#{slice_urn}'."
          @return_struct[:value] = ''
          return ['application/json', JSON.pretty_generate(@return_struct)]
        end
        leases.each do |l|
          tmp = {}
          tmp[:geni_sliver_urn] = l.to_uri
          tmp[:geni_allocation_status] = 'geni_unallocated'
          tmp[:geni_expires] = l.expirationTime.to_s
          value << tmp
        end
      end
      # TODO ELABORATE
      @am_manager.close_samant_account(slice_urn, authorizer)
      #debug "Slice '#{slice_urn}' associated with account '#{account.id}:#{account.closed_at}'"
      debug "Slice '#{slice_urn}' deleted."

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = value
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    rescue OMF::SFA::AM::UnavailableResourceException => e
      @return_struct[:code][:geni_code] = 12 # Search Failed
      @return_struct[:output] = e.to_s
      @return_struct[:value] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]
    end

    # Perform an emergency shut down of a sliver. This operation is
    # intended for administrative use. The sliver is shut down but
    # remains available for further forensics.
    # (close the account but do not release its resources)

    def shutdown(options)
      # TODO Nothing implemented yet for Provision call
      raise OMF::SFA::AM::Rest::BadRequestException.new "Shutdown NOT YET IMPLEMENTED"
    end

    def parse_samant_urns(urns)
      slice_urn = nil
      slivers_only = false

      urns.each do |urn|
        utype = urn_type(urn)
        if utype == "slice" || utype == "account"
          if urns.size != 1 # you can't send more than one slice urns
            return ['', '', 1, 'only one slice urn can be described.']
          end
          slice_urn = urn
          break
        elsif utype == 'lease' || utype == 'sliver'
          lease_urn = RDF::URI.new(urn)
          sparql = SPARQL::Client.new($repository)
          unless sparql.ask.whether([lease_urn, :p, :o]).true?
            return ['', '', 1, "Lease '#{urn}' does not exist."]
          end
          lease = SAMANT::Lease.for(lease_urn)
          debug "Lease Exists with ID = " + lease.hasID.inspect
          new_slice_urn = lease.hasSliceID
          slice_urn = new_slice_urn if slice_urn.nil?
          if new_slice_urn != slice_urn
            return ['', '', 1, "All sliver urns must belong to the same slice."]
          end
          slivers_only = true
        else
          return ['', '', 1, "Only slivers or a slice can be described."]
        end
      end

      [slice_urn, slivers_only, 0, '']
    end

    def urn_type(urn)
      urn.split('+')[-2]
    end

  end
end