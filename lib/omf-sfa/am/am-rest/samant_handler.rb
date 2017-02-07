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

  class SamantHandler < RestHandler

    def find_handler(path, opts)
      debug "!!!SAMANT handler!!!"
      RDF::Util::Logger.logger.parent.level = 'off'
      # debug "PATH = " + path.inspect

      # Define method called
      if path.map(&:downcase).include? "getversion"
        opts[:resource_uri] = "getversion"
      elsif path.map(&:downcase).include? "listresources"
        opts[:resource_uri] = "listresources"
      elsif path.map(&:downcase).include? "describe"
        opts[:resource_uri] = "describe"
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end

      # Define slice urn
      path.any? { |el|
        if el.include?('urn')
          opts[:slice_urn] = el
        end
      }
      if opts[:resource_uri] == "createsliver" && opts[:slice_urn] = nil
        raise OMF::SFA::AM::Rest::BadRequestException.new "Please provide the respective slice."
      end

      # Check if only_available flag is on
      opts[:only_available] = path.include? "only_available"



      return self
    end

    # GET:
    # GetVersion, ListResources, Describe, Status
    #
    # @param method used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_get (method, opts)

      # GetVersion:
      # Return the version of the GENI Aggregate API
      # supported by this aggregate.

      if method == "getversion" # TODO Nothing implemented yet for GetVersion call
        # debug "NOT YET IMPLEMENTED"
        raise OMF::SFA::AM::Rest::BadRequestException.new "getversion NOT YET IMPLEMENTED"

      end
    end

    # POST:
    #   CreateSliver:
    #   Allocate resources to a slice. This operation is expected to start the
    #   allocated resources asynchronously after the operation has
    #   successfully completed. Callers can check on the status of the
    #   resources using SliverStatus.
    #
    # @param function used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_post (method, options)

      # ListResources:
      # Return information about available resources
      # or resources allocated to a slice.

      if method == "listresources"
        body, format = parse_body(options)
        opts = body[:options]
        #debug "Body = ", opts.inspect
        #debug "Format = ", format.inspect
        debug 'ListResources: Options: ', opts.inspect

        only_available = opts[:only_available]
        compressed = opts[:geni_compressed] # TODO Nothing implemented yet for REST API compression
        slice_urn = opts[:slice_urn]
        rspec_version = opts[:geni_rspec_version] # TODO Nothing implemented yet for REST API rspec_version

        authorizer = options[:req].session[:authorizer]
        #debug "!!!USER = " + authorizer.user.inspect
        #debug "!!!ACCOUNT = " + authorizer.account.inspect
        #debug "!!!ACCOUNT_URN = " + authorizer.account[:urn]
        #debug "!!!ACCOUNT = " + authorizer.user.accounts.first.inspect

        # Assume PENDING = pending, ALLOCATED = accepted, PROVISIONED = active, RPC compatibility map
        acceptable_lease_states = [SAMANT::ALLOCATED, SAMANT::PROVISIONED, SAMANT::PENDING]

        if slice_urn
          @return_struct[:code][:geni_code] = 4 # Bad Version
          @return_struct[:output] = "Geni version 3 no longer supports arguement 'geni_slice_urn' for list resources method, please use describe instead."
          @return_struct[:value] = ''
          return ['application/json', JSON.pretty_generate(@return_struct)]
        else
          resources = @am_manager.find_all_samant_leases(nil, acceptable_lease_states, authorizer)
          comps = @am_manager.find_all_samant_components_for_account(nil, authorizer)
          if only_available
            debug "only_available selected"
            comps.delete_if {|c| c.hasResourceStatus.to_uri == SAMANT::BOOKED.to_uri }
          end
          resources.concat(comps)
          #debug "the resources: " + resources.inspect
          used_for_side_effect = OMF::SFA::AM::Rest::ResourceHandler.rspecker(resources) # -> creates the advertisement rspec file inside /ready4translation (less detailed, sfa enabled)
          res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, opts) # -> returns the json formatted results (more detailed, omn enriched)
          # TODO insert identifier to res so to distinguish advertisement from request from manifest etc. (see also am_rpc_service)
        end

        @return_struct[:code][:geni_code] = 0
        @return_struct[:value] = res
        @return_struct[:output] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]

        # Describe:
        # Return information about resources allocated to a slice.

      elsif method == "describe"
        #debug 'Describe: URNS: ', urns.inspect, ' Options: ', options.inspect

        #if urns.nil? || urns.empty?
        #  @return_struct[:code][:geni_code] = 1 # Bad Arguments
        #  @return_struct[:output] = "Arguement 'urns' is either empty or nil."
        #  @return_struct[:value] = ''
        #  return ['application/json', JSON.pretty_generate(@return_struct)]
        #end

        # compressed = options["geni_compressed"] # TODO Nothing implemented yet for REST API compression
        # rspec_version = options["geni_rspec_version"] # TODO Nothing implemented yet for REST API rspec_version

        #if slice_urn
        #  # Must provide full slice URN, e.g /urn:publicid:IDN+omf:netmode+account+__default__
        #  resources = @am_manager.find_all_samant_leases(opts[:slice_urn], acceptable_lease_states, authorizer)
        #  comps = @am_manager.find_all_samant_components_for_account(opts[:slice_urn], authorizer)
        #else
        #  resources = @am_manager.find_all_samant_leases(nil, acceptable_lease_states, authorizer)
        #  comps = @am_manager.find_all_samant_components_for_account(nil, authorizer)
        #end
      end

      rescue OMF::SFA::AM::InsufficientPrivilegesException => e
        @return_struct[:code][:geni_code] = 3
        @return_struct[:output] = e.to_s
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]

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

  end
end