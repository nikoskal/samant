require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
require_relative '../../omn-models/populator.rb'

module OMF::SFA::AM::Rest

  class SamantHandler < RestHandler

    def find_handler(path, opts)
      debug "eimai o samant handler"
      opts[:resource_uri] = nil # anagkastika prepei kati na mpei edw gia na doylepsei mesw tis dispatch, TODO na vgei
      if path.size == 0
        opts[:slice_urn] = nil
        opts[:only_available] = false
      elsif path.size == 1
        opts[:slice_urn] = path[0]
        opts[:only_available] = false
      elsif path.size == 2
        opts[:slice_urn] = path[0]
        opts[:only_available] = true
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
      # debug opts[:slice_urn].to_s + " " + opts[:only_available].to_s
      return self
    end

    # ListResources:
    # Return information about available resources
    # or resources allocated to a slice.
    #
    # @param stud used only for compatibility with previous infrastracture
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_get (stud, opts)
      #debug 'ListResources: Options: ', opts.inspect

      authorizer = opts[:req].session[:authorizer]
      #debug "authenticator " + authenticator.inspect

      if opts[:slice_urn]
        #debug "eimai sto slice urn"

        resources = @am_manager.find_all_samant_leases(authorizer.account, ["pending", "accepted", "active"], authorizer)
        resources.concat(@am_manager.find_all_samant_components_for_account(authorizer.account, authorizer))

      else

        resources = @manager.find_all_samant_leases(nil, ["pending", "accepted", "active"], authorizer)
        comps = @manager.find_all_samant_components_for_account(@am_manager._get_nil_account, authorizer)

        if opts[:only_available]
          debug "only_available flag is true!"
          comps.delete_if {|c| !c.available?}
        end
        resources.concat(comps)
      end

    end

  end
end