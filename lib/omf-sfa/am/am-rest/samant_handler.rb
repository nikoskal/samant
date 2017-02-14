require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
require_relative '../../omn-models/populator.rb'
require 'data_objects'
require 'rdf/do'
require 'do_sqlite3'
$repository = Spira.repository = RDF::DataObjects::Repository.new uri: "sqlite3:./test.db"
require_relative '../../samant_models/sensor.rb'
require_relative '../../samant_models/uxv.rb'

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
        opts[:resource_uri] = "getversion"
      elsif path.map(&:downcase).include? "listresources"
        opts[:resource_uri] = "listresources"
      elsif path.map(&:downcase).include? "describe"
        opts[:resource_uri] = "describe"
      elsif path.map(&:downcase).include? "status"
        opts[:resource_uri] = "status"
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
      if method == "getversion"
        get_version
      elsif method == "listresources"
        list_resources(options)
      elsif method == "describe"
        d_scribe(options)
      elsif method == "status"
        status(options)
      end
    end

    # POST:
    #
    # @param function used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_post (method, options)

        # if function == "createsliver"
        #   rspec_s = opts[:req].body.string
        #   slice_urn = opts[:slice_urn]
        #   authorizer = opts[:req].session[:authorizer]
        #   debug 'CreateSliver: SLICE URN: ', slice_urn , ' RSPEC: ', rspec_s.inspect, ' USERS: ', authorizer.user.inspect
        #
        #   if rspec_s.nil?
        #     # checked in Session Authenticator. You cannot post an empty body message! Returns appropriate error message
        #   end
        #
        #   rspec = JSON.parse(rspec_s) #, :symbolize_names => true) # Returns an array of nested hashes
        #   #debug "is hash? " + rspec.is_a?(Hash).to_s
        #   debug "PARSED RSPEC = " + rspec.inspect
        #   #raise OMF::SFA::AM::UnavailableResourceException.new "BREAKPOINT"
        #   resources = @am_manager.update_samant_resources_from_rspec(rspec, true, authorizer)
        #   debug "returned resources = " + resources.inspect
        #
        #   #resources.pop #removes last element of array
        #   leases_only = true
        #   resources.each do |res|
        #     if !res.kind_of? SAMANT::Lease
        #       #debug "what am i looking? " + res.inspect
        #       #debug "is a lease? "
        #       leases_only = false
        #       break
        #     end
        #   end
        #   # debug "Leases only? " + leases_only.to_s
        #
        #   if resources.nil? || resources.empty? || leases_only
        #     debug('CreateSliver failed', ",all the requested resources were unavailable for the requested DateTime.")
        #
        #     resources.each do |res|
        #       @am_manager.get_scheduler.delete_samant_lease(res) #if res.hasState == Semantic::State.for(:Pending)
        #     end
        #
        #     @return_struct[:code][:geni_code] = 7 # operation refused
        #     @return_struct[:output] = "all the requested resources were unavailable for the requested DateTime."
        #     @return_struct[:value] = ''
        #     return ['application/json', JSON.pretty_generate(@return_struct)]
        #   end
        #
        #   # TODO convert output to Manifest Rspec
        #   OMF::SFA::AM::Rest::ResourceHandler.show_resources_ttl(resources, opts)
        #   # TODO return error rescues structs like rpc
        # end
    end

    # GetVersion:
    # Return the version of the GENI Aggregate API
    # supported by this aggregate.

    def get_version()
      # TODO Nothing implemented yet for GetVersion call
      # debug "NOT YET IMPLEMENTED"
      raise OMF::SFA::AM::Rest::BadRequestException.new "getversion NOT YET IMPLEMENTED"
    end

    # ListResources:
    # Return information about available resources
    # or resources allocated to a slice.

    def list_resources(options)
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
        if only_available
          debug "only_available selected"
          comps.delete_if {|c| c.hasResourceStatus.to_uri == SAMANT::BOOKED.to_uri }
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