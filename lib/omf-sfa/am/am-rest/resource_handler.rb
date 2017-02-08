require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
#require_relative '../../omn-models/populator.rb'

module OMF::SFA::AM::Rest

  # Handles an individual resource
  #
  class ResourceHandler < RestHandler

    # Return the handler responsible for requests to +path+.
    # The default is 'self', but override if someone else
    # should take care of it
    #
    def find_handler(path, opts)
      #opts[:account] = @am_manager.get_default_account
      opts[:resource_uri] = path.join('/')
      if path.size == 0 || path.size == 1
        debug "find_handler: path: '#{path}' opts: '#{opts.inspect}'"
        return self
      elsif path.size == 3 #/resources/type1/UUID/type2 px
        opts[:source_resource_uri] = path[0]
        opts[:source_resource_uuid] = path[1]
        opts[:target_resource_uri] = path[2]
        raise OMF::SFA::AM::Rest::BadRequestException.new "'#{opts[:source_resource_uuid]}' is not a valid UUID." unless UUID.validate(opts[:source_resource_uuid])
        require 'omf-sfa/am/am-rest/resource_association_handler'
        return OMF::SFA::AM::Rest::ResourceAssociationHandler.new(@am_manager, opts)
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
    end

    # List a resource
    # 
    # @param [String] request URI
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.
    def on_get(resource_uri, opts)  # resource uri px "locations", "nodes" klp
      debug "on_get: #{resource_uri}"
      authenticator = opts[:req].session[:authorizer]
      unless resource_uri.empty? # an exeis zitisei resource me sugkekrimeno uri
        resource_type, resource_params = parse_uri(resource_uri, opts) # gurnaei type kai parameters
        if resource_uri == 'leases' # leases, eidiki metaxeirisi
          status_types = ["pending", "accepted", "active"] # default value
          status_types = resource_params[:status].split(',') unless resource_params[:status].nil?

          acc_desc = {}
          acc_desc[:urn] = resource_params.delete(:account_urn) if resource_params[:account_urn]
          acc_desc[:uuid] = resource_params.delete(:account_uuid) if resource_params[:account_uuid]
          account = @am_manager.find_account(acc_desc, authenticator) unless acc_desc.empty?
          
          resource =  @am_manager.find_all_leases(account, status_types, authenticator) # gurnaei ena pinaka me ola ta leases
          return show_resource(resource, opts) # xml/json analoga me ta opts
        end
        descr = {}
        descr.merge!(resource_params) unless resource_params.empty?
        opts[:path] = opts[:req].path.split('/')[0 .. -2].join('/')
        descr[:account_id] = @am_manager.get_scheduler.get_nil_account.id if eval("OMF::SFA::Model::#{resource_type}").can_be_managed? && !@opts[:semantic]
        if descr[:name].nil? && descr[:uuid].nil?
          resource =  @am_manager.find_all_resources(descr, resource_type, authenticator, @opts[:semantic])
        else
          resource = @am_manager.find_resource(descr, resource_type, authenticator, @opts[:semantic])
        end
        return show_resource(resource, opts)
      else # an exeis keno uri, opote ta 8es ola
        debug "list all resources."
        resource = @am_manager.find_all_resources_for_account(opts[:account], @opts[:semantic], authenticator)
      end
      raise UnknownResourceException, "No resources matching the request." if resource.empty?
      show_resource(resource, opts)
    end

    # Update an existing resource
    # 
    # @param [String] request URI
    # @param [Hash] options of the request
    # @return [String] Description of the updated resource.
    def on_put(resource_uri, opts)
      debug "on_put: #{resource_uri}"
      resource = update_resource(resource_uri, true, opts)
      show_resource(resource, opts)
    end

    # Create a new resource
    # 
    # @param [String] request URI
    # @param [Hash] options of the request
    # @return [String] Description of the created resource.
    def on_post(resource_uri, opts) # resource_uri = Nodes
      debug "on_post: #{resource_uri}"
      resource = update_resource(resource_uri, false, opts)
      show_resource(resource, opts)
    end

    # Deletes an existing resource
    # 
    # @param [String] request URI
    # @param [Hash] options of the request
    # @return [String] Description of the created resource.
    def on_delete(resource_uri, opts)
      debug "on_delete: #{resource_uri}"
      delete_resource(resource_uri, opts)
      show_resource(nil, opts) # epistrefei ena sketo "OK"
    end


    # Update resource(s) referred to by +resource_uri+. If +clean_state+ is
    # true, reset any other state to it's default.
    #
    def update_resource(resource_uri, clean_state, opts)
      body, format = parse_body(opts) # parsarei ta dosmena opts eite einai xml eite json, epistrefei array of hashes
      resource_type, resource_params = parse_uri(resource_uri, opts) # parsarei ton tupo twn dedomenwn
      authenticator = opts[:req].session[:authorizer]
      case format
      # when :empty
        # # do nothing
      when :xml
        resource = @am_manager.update_resources_from_xml(body.root, clean_state, opts) # den exei ginei kalo implement se auton ton tomea
      when :json
        if clean_state
          resource = update_a_resource(body, resource_type, authenticator) # clean state = true mpainei edw
        else
          resource = create_new_resource(body, resource_type, authenticator) # clean state = false kanei create
        end
      else
        raise UnsupportedBodyFormatException.new(format)
      end
      resource
    end


    # This methods deletes components, or more broadly defined, removes them
    # from a slice.
    #
    # Currently, we simply transfer components to the +default_sliver+
    #
    def delete_resource(resource_uri, opts)
      body, format = parse_body(opts)
      resource_type, resource_params = parse_uri(resource_uri, opts)
      authenticator = opts[:req].session[:authorizer]
      release_resource(body, resource_type, authenticator)
    end

    # Update the state of +component+ according to inforamtion
    # in the http +req+.
    #
    #
    def update_component_xml(component, modifier_el, opts)
    end

    # Return the state of +component+
    #
    # +component+ - Component to display information about. !!! Can be nil - show only envelope
    #
    def show_resource(resource, opts)
      debug "i m in show resource"
      unless about = opts[:req].path
        throw "Missing 'path' declaration in request"
      end
      path = opts[:path] || about

      case opts[:format]
        when 'xml'
          show_resources_xml(resource, path, opts)
        when 'ttl'
          self.class.omn_response_json(resource, opts)
        else
          show_resources_json(resource, path, opts)
      end
    end

    def show_resources_xml(resource, path, opts)
      #debug "show_resources_xml: #{resource}"
      opts[:href_prefix] = path
      announcement = OMF::SFA::Model::OComponent.sfa_advertisement_xml(resource, opts)
      ['text/xml', announcement.to_xml]
    end

    def show_resources_json(resources, path, opts)
      res = resources ? resource_to_json(resources, path, opts) : {response: "OK"}
      res[:about] = opts[:req].path

      ['application/json', JSON.pretty_generate({:resource_response => res}, :for_rest => true)]
    end

    ### self.tade, alliws einai instance method. emeis tin theloume class method

    def self.omn_response_json(resource, opts)
      debug "show_resources_ttl"
      #['application/json', resource_to_turtle(resource, opts)]
      query_to_omn_json(resource, opts)
    end

    def self.query_to_omn_json(query, opts)
      if query.nil?
        return ::JSON.pretty_generate({:response => "OK", :about => opts[:req].path}) # KARATIA MEGALI 2
      end
      sparql = SPARQL::Client.new($repository)
      res = Array.new
      prev_output = ""
      if query.kind_of?(Array)
        qu_ary = query
      else
        qu_ary = [query]
      end
      qu_ary.each { |query|
        query.each_statement do |s,p,o|
          tmp_query = sparql.construct([s, :p, :o]).where([s, :p, :o])
          output = RDF::JSON::Writer.buffer do |writer|
            writer << tmp_query #$repository
          end
          unless prev_output == output # KARATIA MEGALI
            res << ::JSON.parse(output) # apo JSON se hash, gia na ginei swsto merge
            prev_output = output
          end
        end
      }
      raise UnknownResourceException, "No resources matching the request." if res.empty?
      #debug opts[:req].path
      res << {:about => opts[:req].path}
      #::JSON.pretty_generate(res, :for_rest => true) # apo merged hash se JSON
    end

    # Creates the omn-rspec
    # currently works only for advertisement (offering) rspecs

    def self.rspecker(resources)
      sparql = SPARQL::Client.new($repository)
      uuid = ("urn:uuid:" + SecureRandom.uuid).to_sym # Rspec urn
      rtype_g = [RDF::URI.new(uuid), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
                 RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Offering")]
      rlabel_g = [RDF::URI.new(uuid), RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#label"), "Offering"]
      global_writer = []
      global_writer << rlabel_g << rtype_g

      resources.collect { |rsc|
        # Each UxV !MUST! provide the exact following two Hardware Types:
        hw1 = ("urn:uuid:" + SecureRandom.uuid).to_sym # UxV Hardware Type urn
        hw2 = ("urn:uuid:" + SecureRandom.uuid).to_sym # Sensor Hardware Type urn
        #puts rsc.to_uri
        rsc_uri = rsc.to_uri
        #debug "rsc = " + rsc.to_s
        #debug "rsc_uri = " + rsc_uri.to_s

        # Leases
        global_writer << sparql
                     .construct([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Lease")],
                                [RDF::URI.new(uuid), RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasLease"), rsc_uri])
                     .where([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Lease")])
        global_writer << sparql
                        .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#expirationTime"), :o])
                        .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#expirationTime"), :o])
        global_writer << sparql
                        .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#startTime"), :o])
                        .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#startTime"), :o])
        # Nodes
        global_writer << sparql
                     .construct([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#Node")],
                                [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#isExclusive"), true],
                                [RDF::URI.new(uuid), RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasResource"), rsc_uri],
                                [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn#isResourceOf"), RDF::URI.new(uuid)],
                                [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#hasHardwareType"), RDF::URI.new(hw1)],
                                [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#hasHardwareType"), RDF::URI.new(hw2)],
                                [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#managedBy"), RDF::URI.new("urn:uuid:DUMMY_AUTHORITY")],
                                [RDF::URI.new("urn:uuid:DUMMY_AUTHORITY"), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://open-multinet.info/ontology/omn-domain-geni-fire#AMService")])
                     .where([rsc_uri, :p, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UxV")])
        global_writer << sparql
                    .construct([rsc_uri, RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#label"), :o],
                               [rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasComponentName"), :o])
                    .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#resourceId"), :o])
        global_writer << sparql
                     .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#isAvailable"), true])
                     .where([rsc_uri, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#hasResourceStatus"),
                             RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Released/")])
        global_writer << sparql
                    .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#isAvailable"), false])
                    .where([rsc_uri, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#hasResourceStatus"),
                            RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Booked/")])
        global_writer << sparql
                    .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#isAvailable"), false])
                    .where([rsc_uri, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#hasResourceStatus"),
                            RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#SleepMode/")])
        global_writer << sparql
                     .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#hasInterface"), :o])
                      .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#hasInterface"), :o])
        global_writer << sparql
                      .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#hasLocation"), :o])
                      .where([rsc_uri, RDF::URI.new("http://www.georss.org/georss/where"), :o])

        # Interfaces
        global_writer << sparql
                    .construct([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#Interface")])
                    .where([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#WiredInterface")])
        global_writer << sparql
                    .construct([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-resource#Interface")])
                    .where([rsc_uri, :p, RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#WirelessInterface")])
        global_writer << sparql
                    .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasComponentID"), :o])
                    .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasComponentID"), :o])
        global_writer << sparql
                      .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasComponentName"), :o])
                      .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasComponentName"), :o])
        global_writer << sparql
                      .construct([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasRole"), :o])
                      .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#hasRole"), :o])

        # Hardware Types
        global_writer << sparql
                             .construct([RDF::URI.new(hw1), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://open-multinet.info/ontology/omn-resource#HardwareType")],
                                        [RDF::URI.new(hw1), RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#label"), :o])
                             .where([rsc_uri, RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#resourceId"), :o],
                                    [rsc_uri, :p, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UxV")])
        global_writer << sparql
                             .construct([RDF::URI.new(hw2), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://open-multinet.info/ontology/omn-resource#HardwareType")],
                                        [RDF::URI.new(hw2), RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#label"), :o])
                             .where([rsc_uri, :p, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UxV")],
                                    [rsc_uri, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#hasSensorSystem"), :s],
                                    [:s, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#hasID"), :o]
                             )
        # Locations
        global_writer << sparql
                             .construct([rsc_uri, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://open-multinet.info/ontology/omn-resource#Location")],
                                        [rsc_uri, RDF::URI.new("http://www.geonames.org/ontology#countryCode"), "DUMMY_COUNTRYCODE"])
                             .where([rsc_uri, :p, RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Point3D")])
        global_writer << sparql
                             .construct([rsc_uri, RDF::URI.new("http://www.w3.org/2003/01/geo/wgs84_pos#lat"), :o])
                             .where([rsc_uri, RDF::URI.new("http://www.w3.org/2003/01/geo/wgs84_pos#lat"), :o])
        global_writer << sparql
                             .construct([rsc_uri, RDF::URI.new("http://www.w3.org/2003/01/geo/wgs84_pos#long"), :o])
                             .where([rsc_uri, RDF::URI.new("http://www.w3.org/2003/01/geo/wgs84_pos#long"), :o])
        #debug "is it array? " + global_writer.kind_of?(Array).to_s
      }
      RDF::Turtle::Writer.open("ready4translation/adv_rspec.ttl") do |writer|
        global_writer.collect { |g|
          writer << g
        }
      end

    end

    def resource_to_json(resource, path, opts, already_described = {})
      debug "resource_to_json: resource: #{resource.inspect}, path: #{path}"
      if resource.kind_of? Enumerable
        res = []
        resource.each do |r|
          p = path
          res << resource_to_json(r, p, opts, already_described)[:resource]
        end
        res = {:resources => res} # hash
      else
        #prefix = path.split('/')[0 .. -2].join('/') # + '/'
        prefix = path
        if resource.respond_to? :to_sfa_hashXXX
          debug "TO_SFA_HASH: #{resource}"
          res = {:resource => resource.to_sfa_hash(already_described, :href_prefix => prefix)}
        else
          rh = resource.to_hash

          # unless (account = resource.account) == @am_manager.get_default_account()
            # rh[:account] = {:uuid => account.uuid.to_s, :name => account.name}
          # end
          res = {:resource => rh}
        end
      end
      res
    end

    protected

    def parse_uri(resource_uri, opts)
      params = opts[:req].params.symbolize_keys!
      params.delete("account")

      return ['mapper', params] if opts[:req].env["REQUEST_PATH"] == '/mapper'

      case resource_uri
      when "cmc"
        type = "ChasisManagerCard"
      when "wimax"
        type = "WimaxBaseStation"
      when "lte"
        type = "ENodeB"
      when "openflow"
        type = "OpenflowSwitch"
      else
        type = resource_uri.singularize.camelize # to kanei eniko, kefalaio prwto, diwxnei underscores
        begin
          eval("OMF::SFA::Model::#{type}").class
        rescue NameError => ex
          raise OMF::SFA::AM::Rest::UnknownResourceException.new "Unknown resource type '#{resource_uri}'."
        end
      end
      debug "parse uri " + type
      [type, params]
    end

    # Create a new resource
    #
    # @param [Hash] Describing properties of the requested resource
    # @param [String] Type to create
    # @param [Authorizer] Defines context for authorization decisions
    # @return [OResource] The resource created
    # @raise [UnknownResourceException] if no resource can be created
    #
    def create_new_resource(resource_descr, type_to_create, authorizer)
      debug "create_new_resource: resource_descr: #{resource_descr}, type_to_create: #{type_to_create}"
      authorizer.can_create_resource?(resource_descr, type_to_create)

      if type_to_create == "Lease" #Lease is a unigue case, needs special treatment
        raise OMF::SFA::AM::Rest::BadRequestException.new "Attribute account is mandatory." if resource_descr[:account].nil? && resource_descr[:account_attributes].nil?
        raise OMF::SFA::AM::Rest::BadRequestException.new "Attribute components is mandatory." if (resource_descr[:components].nil? || resource_descr[:components].empty?) && (resource_descr[:components_attributes].nil? || resource_descr[:components_attributes].empty?)
        raise OMF::SFA::AM::Rest::BadRequestException.new "Attributes valid_from and valid_until are mandatory." if resource_descr[:valid_from].nil? || resource_descr[:valid_until].nil?

        res_descr = {} # praktika ena hash/antigrafo tou resource description, me kapoia epipleon
        res_descr[:name] = resource_descr[:name]
        res_descr[:valid_from] = resource_descr[:valid_from]
        res_descr[:valid_until] = resource_descr[:valid_until]
        ac_desc = resource_descr[:account] || resource_descr[:account_attributes] # praktika simainei opoio ap ta 2 uparxei
        ac = OMF::SFA::Model::Account.first(ac_desc)
        raise OMF::SFA::AM::Rest::UnknownResourceException.new "Account with description '#{ac_desc}' does not exist." if ac.nil? 
        raise OMF::SFA::AM::Rest::NotAuthorizedException.new "Account with description '#{ac_desc}' is closed." unless ac.active?
        res_descr[:account_id] = ac.id
        lease = @am_manager.find_or_create_lease(res_descr, authorizer)  # Return the lease described by +lease_descr+. Create if it doesn't exist.

        comps = resource_descr[:components] || resource_descr[:components_attributes]
        nil_account_id = @am_manager._get_nil_account.id # default account, admin account
        components = []
        comps.each do |c|
          desc = {}
          desc[:account_id] = nil_account_id
          desc[:uuid] = c[:uuid] unless c[:uuid].nil?
          desc[:name] = c[:name] unless c[:name].nil?
          if k = OMF::SFA::Model::Resource.first(desc)
            components << k #vres to component me to tade uuid h name (analoga ti exei do8ei) kai valto ston pinaka components
          end
        end 

        scheduler = @am_manager.get_scheduler
        comps = []
        components.each do |comp|
          comps << c = scheduler.create_child_resource({uuid: comp.uuid, account_id: ac.id}, comp[:type].to_s.split('::').last)
          unless scheduler.lease_component(lease, c)
            scheduler.delete_lease(lease)
            @am_manager.release_resources(comps, authorizer) # kanei destroy ta resources
            raise NotAuthorizedException.new "Reservation for the resource '#{c.name}' failed. The resource is either unavailable or a policy quota has been exceeded."
          end
        end
        resource = lease
      else
        if resource_descr.kind_of? Array
          descr = []
          resource_descr.each do |res|
            res_descr = {}
            res_descr.merge!({uuid: res[:uuid]}) if res.has_key?(:uuid) # an sto hash uparxei kleisi "uuid"
            res_descr.merge!({name: res[:name]}) if res.has_key?(:name) # ftiaxnei ena hashaki me to uuid kai to name kai to vazei ston pinaka descr
            descr << res_descr unless eval("OMF::SFA::Model::#{type_to_create}").first(res_descr) # ektos an uparxei hdh
          end # elegxei an ta resources uparxoun
          raise OMF::SFA::AM::Rest::BadRequestException.new "No resources described in description #{resource_descr} is valid. Maybe all the resources alreadt=y exist." if descr.empty?
        elsif resource_descr.kind_of? Hash
          descr = {}
          descr.merge!({uuid: resource_descr[:uuid]}) if resource_descr.has_key?(:uuid)
          descr.merge!({name: resource_descr[:name]}) if resource_descr.has_key?(:name)
        
          if descr.empty?
            raise OMF::SFA::AM::Rest::BadRequestException.new "Resource description is '#{resource_descr}'."
          else
            raise OMF::SFA::AM::Rest::BadRequestException.new "Resource with descr '#{descr} already exists'." if eval("OMF::SFA::Model::#{type_to_create}").first(descr)
          end
        end

        if resource_descr.kind_of? Array # logika an exeis dosei polla resources
          resource = []
          resource_descr.each do |res_desc|
            resource << eval("OMF::SFA::Model::#{type_to_create}").create(res_desc)
            @am_manager.manage_resource(resource.last) if resource.last.account.nil?
            if type_to_create == 'Account'
              @am_manager.liaison.create_account(resource.last)
            end
          end
        elsif resource_descr.kind_of? Hash # an exeis dwsei ena resource

          # EXW PEIRAKSEI

          if @opts[:semantic]
            debug "semantic creation"
            sparql = SPARQL::Client.new($repository)
            id = resource_descr[:name]
            resource_descr.delete(:name)
            res = eval("Semantic::#{type_to_create}").for(id, resource_descr)
            res.save!
            resource = sparql.construct([res.uri, :p,  :o]).where([res.uri, :p, :o])

            ##############
          else
            resource = eval("OMF::SFA::Model::#{type_to_create}").create(resource_descr)
            @am_manager.manage_resource(resource) if resource.class.can_be_managed?
            if type_to_create == 'Account'
              @am_manager.liaison.create_account(resource)
            end
          end
        end
      end
      resource
    end

    # Update a resource
    #
    # @param [Hash] Describing properties of the requested resource
    # @param [String] Type to create
    # @param [Authorizer] Defines context for authorization decisions
    # @return [OResource] The resource created
    # @raise [UnknownResourceException] if no resource can be created
    #
    def update_a_resource(resource_descr, type_to_create, authorizer)
      descr = {}
      descr.merge!({uuid: resource_descr[:uuid]}) if resource_descr.has_key?(:uuid)
      descr.merge!({name: resource_descr[:name]}) if descr[:uuid].nil? && resource_descr.has_key?(:name)

      # EXW PEIRAKSEI -> THELEI POLLES ALLAGES, POLY PROXEIRO

      if @opts[:semantic]
        debug "semantic UPDATE"
        sparql = SPARQL::Client.new($repository)
        id = resource_descr[:name]
        resource_descr.delete(:name)
        res = eval("Semantic::#{type_to_create}").for(id).update_attributes(resource_descr)
        return sparql.construct([res.uri, :p,  :o]).where([res.uri, :p, :o])

        ##############
      else

        unless descr.empty?
          if resource = eval("OMF::SFA::Model::#{type_to_create}").first(descr) # prwta ferto, meta kanto update
            authorizer.can_modify_resource?(resource, type_to_create)
            resource.update(resource_descr) # to resource description exei parsaristei kai ginetai katallila to update sti vasi dedomenwn
            @am_manager.get_scheduler.update_lease_events_on_event_scheduler(resource) if type_to_create == 'Lease'
            # @am_manager.manage_resource(resource)
          else
            raise OMF::SFA::AM::Rest::UnknownResourceException.new "Unknown resource with descr'#{resource_descr}'."
          end
        end

      end
      resource
    end

    # Release a resource
    #
    # @param [Hash] Describing properties of the requested resource
    # @param [String] Type to create
    # @param [Authorizer] Defines context for authorization decisions
    # @return [OResource] The resource created
    # @raise [UnknownResourceException] if no resource can be created
    #
    def release_resource(resource_descr, type_to_release, authorizer)

      if type_to_release == "Lease" #Lease is a unigue case, needs special treatment
        if resource = OMF::SFA::Model::Lease.first(resource_descr)
          @am_manager.release_lease(resource, authorizer)
        else
          raise OMF::SFA::AM::Rest::UnknownResourceException.new "Unknown Lease with descr'#{resource_descr}'."
        end
      else

        # EXW PEIRAKSEI ####

        if @opts[:semantic]
          debug "semantic delete"
          #id = resource_descr[:name]
          resource = eval("Semantic::#{type_to_release}").for(resource_descr[:name])
          debug resource.inspect
          resource.destroy

          ##############
        else

          authorizer.can_release_resource?(resource_descr)
          if resource = eval("OMF::SFA::Model::#{type_to_release}").first(resource_descr)
            if type_to_release == 'Account'
              @am_manager.liaison.close_account(resource)
            end
            resource.destroy
          else
            raise OMF::SFA::AM::Rest::UnknownResourceException.new "Unknown resource with descr'#{resource_descr}'."
          end
        end

      end
      resource
    end

    # Before create a new resource, parse the resource description and alternate existing resources.
    #
    # @param [Hash] Resource Description
    # @return [Hash] New Resource Description
    # @raise [UnknownResourceException] if no resource can be created
    #
    def parse_resource_description(resource_descr, type_to_create)
      resource_descr.each do |key, value|
        debug "checking prop: '#{key}': '#{value}': '#{type_to_create}'"
        if value.kind_of? Array
          value.each_with_index do |v, i|
            if v.kind_of? Hash
              # debug "Array: #{v.inspect}"
              begin
                k = eval("OMF::SFA::Model::#{key.to_s.singularize.capitalize}").first(v)
                raise NameError if k.nil?
                resource_descr[key][i] = k
              rescue NameError => nex
                model = eval("OMF::SFA::Model::#{type_to_create}.get_oprops[key][:__type__]")
                resource_descr[key][i] = (k = eval("OMF::SFA::Model::#{model}").first(v)) ? k : v
              end
            end
          end
        elsif value.kind_of? Hash
          debug "Hash: #{key.inspect}: #{value.inspect}"
          begin
            k = eval("OMF::SFA::Model::#{key.to_s.singularize.capitalize}").first(value)
            raise NameError if k.nil?
            resource_descr[key] = k
          rescue NameError => nex
            model = eval("OMF::SFA::Model::#{type_to_create}.get_oprops[key][:__type__]")
            resource_descr[key] = (k = eval("OMF::SFA::Model::#{model}").first(value)) ? k : value
          end
        end
      end
      resource_descr
    end

  end # ResourceHandler
end # module
