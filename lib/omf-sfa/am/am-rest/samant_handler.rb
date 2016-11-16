require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
require_relative '../../omn-models/populator.rb'

module OMF::SFA::AM::Rest

  class SamantHandler < RestHandler

    def find_handler(path, opts)
      debug "!!!SAMANT handler!!!"

      if path.size == 0
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
        # xrisimopoioume tin resource uri gia na perasoume poia function theloume na klithei
      elsif path.size == 1
        opts[:resource_uri] = path[0].downcase
        if opts[:resource_uri] == "getversion"
        elsif opts[:resource_uri] == "listresources"
          opts[:slice_urn] = nil
          opts[:only_available] = false # default == false
        elsif opts[:resource_uri] == "createsliver"
          raise OMF::SFA::AM::Rest::BadRequestException.new "Provide the respective slice."
        end

      elsif path.size == 2
        opts[:resource_uri] = path[0].downcase
        if opts[:resource_uri] == "getversion"
          raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
        elsif opts[:resource_uri] == "listresources"
          opts[:slice_urn] = path[1]
          opts[:only_available] = false
        elsif opts[:resource_uri] == "createsliver"
          opts[:slice_urn] = path[1]
        end

      elsif path.size == 3
        opts[:resource_uri] = path[0].downcase
        if opts[:resource_uri] == "getversion"
          raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
        elsif opts[:resource_uri] == "listresources"
          opts[:slice_urn] = path[1]
          opts[:only_available] = (path[2].downcase == "true")
        elsif opts[:resource_uri] == "createsliver"
          raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
        end

      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
       #debug opts[:slice_urn].to_s + " " + opts[:only_available].to_s
      return self
    end

    # GET:
    # GetVersion, ListResources, SliverStatus
    #
    # @param function used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_get (function, opts)

      # GetVersion:
      # Return the version of the GENI Aggregate API
      # supported by this aggregate.

      if function == "getversion"
        debug "NOT YET IMPLEMENTED"
        raise OMF::SFA::AM::Rest::BadRequestException.new "NOT YET IMPLEMENTED"

        # ListResources:
        # Return information about available resources
        # or resources allocated to a slice.

      elsif function == "listresources"
        debug 'ListResources: Options: ', opts.inspect

        authorizer = opts[:req].session[:authorizer]
        #debug "!!!USER = " + authorizer.user.inspect
        #debug "!!!ACCOUNT = " + authorizer.account.inspect
        #debug "!!!ACCOUNT_URN = " + authorizer.account[:urn]
        #debug "!!!ACCOUNT = " + authorizer.user.accounts.first.inspect

        acceptable_lease_states = [Semantic::State.for(:Pending), Semantic::State.for(:Success), Semantic::State.for(:Active)]

        if opts[:slice_urn]
          # Must provide full slice URN, e.g /urn:publicid:IDN+omf:netmode+account+__default__
          resources = @am_manager.find_all_samant_leases(opts[:slice_urn], acceptable_lease_states, authorizer)
          comps = @am_manager.find_all_samant_components_for_account(opts[:slice_urn], authorizer)
        else
          resources = @am_manager.find_all_samant_leases(nil, acceptable_lease_states, authorizer)
          comps = @am_manager.find_all_samant_components_for_account(nil, authorizer)
        end
        if opts[:only_available]
          debug "NOT YET IMPLEMENTED"
          raise OMF::SFA::AM::Rest::BadRequestException.new "NOT YET IMPLEMENTED"
          #comps.delete_if {|c| !c.available?}
        end
        resources.concat(comps)
        #debug "resources " + resources.inspect
        OMF::SFA::AM::Rest::ResourceHandler.show_resources_ttl(resources, opts)
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

    def on_post (function, opts)

      if function == "createsliver"
        rspec_s = opts[:req].body.string
        slice_urn = opts[:slice_urn]
        authorizer = opts[:req].session[:authorizer]
        debug 'CreateSliver: SLICE URN: ', slice_urn , ' RSPEC: ', rspec_s.inspect, ' USERS: ', authorizer.user.inspect

        if rspec_s.nil?
          # checked in Session Authenticator. You cannot post an empty body message! Returns appropriate error message
        end

        rspec = JSON.parse(rspec_s) #, :symbolize_names => true) # Returns an array of nested hashes
        #debug "is hash? " + rspec.is_a?(Hash).to_s
        resources = @am_manager.update_samant_resources_from_rspec(rspec, true, authorizer)
        debug "PARSED RSPEC = " + rspec.inspect

        raise OMF::SFA::AM::Rest::BadRequestException.new "NOT YET IMPLEMENTED"
      end

    end

  end
end