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
      #unless @@ip_whitelist.include?(remote_ip)
      #  raise OMF::SFA::AM::Rest::BadRequestException.new "Anauthorized access!"
      #end
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
      body, format = parse_body(options)
      params = body[:options]
      authorizer = options[:req].session[:authorizer]
      resources = get_info(params)
      res = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(res)]
    end

    def on_post (method, options)
      body, format = parse_body(options)
      res_el = body[:resources]
      authorizer = options[:req].session[:authorizer]
      resources = create_or_update(res_el, false, authorizer)
      resp = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    def on_put (method, options)
      body, format = parse_body(options)
      res_el = body[:resources]
      authorizer = options[:req].session[:authorizer]
      resources = create_or_update(res_el, true, authorizer)
      resp = OMF::SFA::AM::Rest::ResourceHandler.omn_response_json(resources, options)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    def on_delete (method, options)
      body, format = parse_body(options)
      resources = body[:resources]
      authorizer = options[:req].session[:authorizer]
      resp = delete(resources, authorizer)
      return ['application/json', JSON.pretty_generate(resp)]
    end

    # Retain info based on class/urn

    def get_info(params)
      debug 'Admin ListResources: Options: ', params.inspect
      category = params[:type]
      descr = params[:description]
      descr = find_doctor(descr)

      if category # if applied specific resource type
        debug "descr = " + descr.inspect
        resources = @am_manager.find_all_samant_resources(category, descr)
      elsif urns = params[:urns] # if applied for certain urns
        resources = @am_manager.find_all_samant_resources(nil, descr)
        resources.delete_if {|c| !urns.include?(c.to_uri.to_s)}
      end
      resources.delete_if {|c| c.to_uri.to_s.include?"/leased"} unless resources.nil?
      resources
    end

    # Create or Update SAMANT resources. If +clean_state+ is true, resources are updated, else they are created from scratch.

    def create_or_update(res_el, clean_state, authorizer)
      sparql = SPARQL::Client.new($repository)
      debug 'Admin CreateOrUpdate: resources: ', res_el.inspect

      unless res_el.is_a?(Array)
        res_el = [res_el]
      end
      resources = []
      res_el.each do |params|
        descr = params[:resource_description]
        descr = create_doctor(descr, authorizer) # Connect the objects first
        if clean_state # update
          urn = params[:urn]
          type = OMF::SFA::Model::GURN.parse(urn).type.camelize
          res = eval("SAMANT::#{type}").for(urn)
          unless sparql.ask.whether([res.to_uri, :p, :o]).true?
            raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{res.inspect}' not found. Please create that first."
          end
          authorizer.can_modify_resource?(res, type)
          res.update_attributes(descr) # Not sure if different than ".for(urn, new_descr)" regarding an already existent urn
        else # create
          unless params[:name] && params[:type] && params[:authority]
            raise OMF::SFA::AM::Rest::BadRequestException.new "One of the following mandatory parameters is missing: name, type, authority."
          end
          urn = OMF::SFA::Model::GURN.create(params[:name], {:type => params[:type], :domain => params[:authority]})
          type = params[:type].camelize
          descr[:hasID] = SecureRandom.uuid # Every resource must have a uuid
          res = eval("SAMANT::#{type}").for(urn, descr) # doesn't save unless you explicitly define so
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

    def delete(resources, authorizer)
      sparql = SPARQL::Client.new($repository)
      debug 'Admin Delete: resources: ', resources.inspect

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

    def create_doctor(descr, authorizer)
      sparql = SPARQL::Client.new($repository)
      descr.each do |key, value|
        debug "key = " + key.to_s
        next if key == :hasComponentID || key == :hasSliceID # These *strings* are permitted to contain the "urn" substring
        if value.is_a?(Array)
          arr_value = value
          new_array = []
          arr_value.each do |v|
            v = create_or_update(v, false, authorizer).first.uri.to_s if v.is_a?(Hash) # create the described object
            gurn = OMF::SFA::Model::GURN.parse(v) # Assumes "v" is a urn
            unless gurn.type && gurn.name
              raise OMF::SFA::AM::Rest::UnsupportedBodyFormatException.new "Invalid URN: " + v.to_s
            end
            new_res = eval("SAMANT::#{gurn.type.camelize}").for(gurn.to_s)
            unless sparql.ask.whether([new_res.to_uri, :p, :o]).true?
              raise OMF::SFA::AM::Rest::BadRequestException.new "Resource '#{new_res.inspect}' not found. Please create that first."
            end
            new_array << new_res
          end
          debug "New Array contains: " + new_array.inspect
          descr[key] = new_array
        else
          value = create_or_update(value, false, authorizer).first.uri.to_s if value.is_a?(Hash) # create the described object
          if value.include? "urn" # Object found, i.e uxv, sensor etc
            gurn = OMF::SFA::Model::GURN.parse(value)
            unless gurn.type
              raise OMF::SFA::AM::Rest::UnsupportedBodyFormatException.new "Invalid URN: " + value.to_s
            end
            descr[key] = eval("SAMANT::#{gurn.type.camelize}").for(gurn.to_s)
          elsif value.include? "http" # Instance found, i.e HealthStatus, Resource Status etc
            type = value.split("#").last.chop
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
      debug "New Hash contains: " + descr.inspect
      descr
    end

    # Find instances

    def find_doctor(descr)
      descr.each do |key,value|
        if value.is_a?(Hash)
          new_value = get_info(value).first.uri.to_s
          descr[key] = RDF::URI(new_value)
        end
      end
      descr
    end

  end
end
