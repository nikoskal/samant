require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'

module OMF::SFA::AM::Rest
  class SamantAdminHandler < RestHandler
    @@ip_whitelist = ['127.0.0.1'].freeze

    def find_handler(path, opts)
      debug "!!!ADMIN handler!!!"
      remote_ip = opts[:req].env["REMOTE_ADDR"]
      debug "Trying to connect from >>>>> " + remote_ip
      #debug "what contains? " + @@ip_whitelist.inspect
      #debug "contains? " + @@ip_whitelist.include?(remote_ip).to_s
      unless @@ip_whitelist.include?(remote_ip)
        raise OMF::SFA::AM::Rest::BadRequestException.new "Anauthorized access!"
      end
      RDF::Util::Logger.logger.parent.level = 'off' # Worst Bug *EVER*
      if path.map(&:downcase).include? "getinfo"
        opts[:resource_uri] = :getinfo
      elsif path.map(&:downcase).include? "create"
        opts[:resource_uri] = :create
      elsif path.map(&:downcase).include? "update"
        opts[:resource_uri] = :update
      elsif path.map(&:downcase).include? "delete"
        opts[:resource_uri] = :delete
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
      return self
    end

    def on_get (method, options)
      resources = get_info(options)
      res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(res)]
    end

    def on_post (method, options)
      resources = create_or_update(options, false)
      resp = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    def on_put (method, options)
      resources = create_or_update(options, true)
      resp = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    def on_delete (method, options)
      resp = delete(options)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    # Retain info based on class/urn

    def get_info(options)
      body, format = parse_body(options)
      params = body[:options]
      debug 'Admin ListResources: Options: ', params.inspect
      authorizer = options[:req].session[:authorizer]
      category = params[:type]

      if category # if applied for everything
        resources = @am_manager.find_all_samant_resources(category)
      elsif urns = params[:urns] # if applied for certain urns
        resources = @am_manager.find_all_samant_resources()
        resources.delete_if {|c| !urns.include?(c.to_uri.to_s)}
      end
      resources.delete_if {|c| c.to_uri.to_s.include?"/leased"}
      resources
    end

    # Create or Update SAMANT resources. If +clean_state+ is true, resources are updated, else they are created from scratch.

    def create_or_update(options, clean_state)
      sparql = SPARQL::Client.new($repository)
      body, format = parse_body(options)
      res_el = body[:resources]
      debug 'Admin CreateOrUpdate: resources: ', res_el.inspect
      authorizer = options[:req].session[:authorizer]

      unless res_el.is_a?(Array)
        res_el = [res_el]
      end
      resources = []
      res_el.each do |params|
        descr = params[:resource_description]
        descr = connector(descr) # Connect the objects first
        if clean_state # update
          urn = params[:urn]
          type = OMF::SFA::Model::GURN.parse(urn).type.camelize
          res = eval("SAMANT::#{type}").for(urn)
          unless sparql.ask.whether([res.to_uri, :p, :o]).true?
            raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{res.inspect}' not found. Please create that first."
          end
          authorizer.can_modify_resource?(res, type)
          res.update_attributes(descr)
        else # create
          urn = OMF::SFA::Model::GURN.create(params[:name], {:type => params[:type], :domain => params[:authority]})
          type = params[:type].camelize
          #debug "type, urn, descr: " + type.inspect + " " + urn.inspect + " " + descr.inspect
          descr[:hasID] = SecureRandom.uuid # Every resource must have a uuid
          res = eval("SAMANT::#{type}").for(urn, descr)
          unless sparql.ask.whether([res.to_uri, :p, :o]).false?
            raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{res.inspect}' already exists."
          end
          authorizer.can_create_resource?(res, type)
          res.save!
        end
        resources << res
      end
      resources
    end

    # Delete SAMANT resources

    def delete(options)
      sparql = SPARQL::Client.new($repository)
      body, format = parse_body(options)
      resources = body[:resources]
      debug 'Admin Delete: resources: ', resources.inspect
      authorizer = options[:req].session[:authorizer]

      unless resources.is_a?(Array)
        resources = [resources]
      end
      resources.each do |resource|
        urn = resource[:urn]
        gurn = OMF::SFA::Model::GURN.parse(resource[:urn])
        type = gurn.type.camelize
        res = eval("SAMANT::#{type}").for(urn)
        if res.is_a?SAMANT::Uxv
          res.hasComponentID = nil # F*ing bug
          res.save!
        end
        unless sparql.ask.whether([res.to_uri, :p, :o]).true?
          raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{res.inspect}' not found. Please create that first."
        end
        authorizer.can_release_resource?(res)
        res.destroy!
        return {:response => "Resource Successfully Deleted"}
      end
    end

    # Connect instances before creating/updating

    def connector(descr)
      sparql = SPARQL::Client.new($repository)
      descr.each do |key, value|
        debug "key = " + key.to_s
        next if key == :hasComponentID || key == :hasSliceID # These *strings* are permitted to contain the "urn" substring
        if value.is_a?(Array)
          arr_value = value
          new_array = []
          arr_value.each do |v|
            gurn = OMF::SFA::Model::GURN.parse(v)
            unless gurn.type && gurn.name
              raise OMF::SFA::AM::Rest::UnsupportedBodyFormatException.new "Invalid URN: " + v.to_s
            end
            debug "type = " + gurn.type
            debug "name = " + gurn.name
            new_res = eval("SAMANT::#{gurn.type.camelize}").for(gurn.to_s)
            unless sparql.ask.whether([new_res.to_uri, :p, :o]).true?
              raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{new_res.inspect}' not found. Please create that first."
            end
            new_array << new_res
          end
          debug "Array = " + new_array.inspect
          descr[key] = new_array
        else
          if value.include? "urn" # Object found, i.e uxv, sensor etc
            gurn = OMF::SFA::Model::GURN.parse(value)
            unless gurn.type
              raise OMF::SFA::AM::Rest::UnsupportedBodyFormatException.new "Invalid URN: " + value.to_s
            end
            debug "type = " + gurn.type
            debug "gurn = " + gurn.to_s
            descr[key] = eval("SAMANT::#{gurn.type.camelize}").for(gurn.to_s)
          elsif value.include? "http" # Instance found, i.e HealthStatus, Resource Status etc
            type = value.split("#").last.chop
            debug "type = " + type
            new_res = eval("SAMANT::#{type}").for("")
            unless sparql.ask.whether([new_res.to_uri, :p, :o]).true?
              raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{new_res.inspect}' not found. Please create that first."
            end
            descr[key] = new_res
          elsif value == "nil"
            descr[key] = nil
          end
        end
      end
      debug "new hash = " + descr.inspect
      descr
    end

  end
end
