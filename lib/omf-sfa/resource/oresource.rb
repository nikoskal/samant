require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'omf_common/lobject'
require 'set'
require 'active_support/inflector'
require 'uuid'

#require 'omf-sfa/resource/oproperty'
autoload :OProperty, 'omf-sfa/resource/oproperty'
#require 'omf-sfa/resource/group_membership'
autoload :GroupMembership, 'omf-sfa/resource/group_membership'
autoload :Account, 'omf-sfa/resource/account'
autoload :OGroup, 'omf-sfa/resource/ogroup'
autoload :Lease, 'omf-sfa/resource/lease'

# module OMF::SFA::Resource
  # class OResource; end
# end
#require 'omf-sfa/resource/account'


module OMF::SFA::Resource

  # This is the basic resource from which all other
  # resources descend.
  #
  # Note: Can't call it 'Resource' to avoid any confusion
  # with DataMapper::Resource
  #
  class OResource
    include OMF::Common::Loggable
    extend OMF::Common::Loggable # debug

    include DataMapper::Resource
    include DataMapper::Validations

    #@@default_href_prefix = 'http://somehost/resources/'
    @@default_href_prefix = '/resources'

    @@oprops = {}

    # managing dm object, dm = datamapper
    property :id,   Serial
    property :type, Discriminator

    property :uuid, UUID
    property :name, String
    #property :href, String, :length => 255, :default => lambda {|r, m| r.def_href() }
    property :urn, String, :length => 255
    property :resource_type, String

    has n, :o_properties, 'OProperty'
    alias oproperties o_properties


    #has n, :contained_in_groups, :model => :Group, :through => GroupMembership
    #has n, :contained_in_groups, 'Group' #, :through => :group_membership #GroupMembership

    #has n, :group_memberships
    #has n, :groups, 'Group', :through => :group_membership #, :via => :groups

    has n, :group_memberships, :child_key => [ :o_resource_id ]
    has n, :included_in_groups, 'OGroup', :through => :group_memberships, :via => :o_group

    belongs_to :account, :model => 'Account', :child_key  => [ :account_id ], :required => false

    def self.get_oprops
      @@oprops[self]
    end

    # Override of the Class method 'first' of DataMapper such that we can search with oproperties
    def self.first(*args)
      class_props = @@oprops[self]

      if args.empty? || class_props.nil?
        return super(*args)
      elsif !args.last.kind_of? Enumerable
        # if we get a possible Object argument then use DataMapper's first method
        return super(*args)
      end

      # we separate properties from oproperties
      query = args.last.dup
      oprops = query.select do |k|
        if k.is_a? String
          k = k.to_sym
        end
        class_props.include?(k)
      end
      query.delete_if do |k|
        if k.is_a? String
          k = k.to_sym
        end
        class_props.include?(k)
      end

      if oprops.empty?
        # nothing to do here just use DataMapper's first method
        return super(*args)
      else
        # get all the resources that match the properties desctription and then
        # we will pick the first one that matches the oproperties description
        res = self.all(query)
      end

      res.each do |r|
        catch :diff_prop do
          oprops.each do |key, value|
            key = key.to_sym unless key.is_a? Symbol
            type = class_props[key][:__type__]
            if type.is_a? Symbol
              if class_props[key][:functional].nil?
                unless value.is_a? eval(type.to_s)
                  value = eval(class_props[key][:__type__].to_s).first(value)
                end
              elsif class_props[key][:functional] == false
                if value.is_a? Array
                  value = value.map do |v|
                    if v.is_a? eval(type.to_s)
                      v
                    else
                      eval(class_props[key][:__type__].to_s).first(v)
                    end
                  end
                else
                  unless value.is_a? eval(type.to_s)
                    value = eval(class_props[key][:__type__].to_s).first(value)
                  end
                  value = [value]
                end
              elsif class_props[key][:functional] == true
                unless value.is_a? eval(type.to_s)
                  value = eval(class_props[key][:__type__].to_s).first(value)
                end
              end
            end # if Symbol
            throw :diff_prop if r.send(key) != value
          end
          return r # all the oproperties of this resource match with the query
        end # throw will end up here and continue with the next res
      end
      return nil # nothing found
    end

    def self.oproperty(name, type, opts = {})
      name = name.to_s

      # should check if +name+ is already used
      op = @@oprops[self] ||= {}
      opts[:__type__] = type

      if opts[:functional] == false
        # property is an array
        pname = DataMapper::Inflector.pluralize(name)
        op[pname.to_sym] = opts

        define_method pname do
          res = oproperty_get(pname)
          if res == nil
            oproperty_set(pname, res = [])
            # We make a oproperty_get in order to get the extended Array with
            # the overidden '<<' method. Check module ArrayProxy in oproperty.rb
            res = oproperty_get(pname)
          end
          #puts "PROPERTY_GET #{res}"
          res
        end

        define_method "#{pname}=" do |v|

          if (type.is_a? Symbol) && (!v.nil?)
            # make sure i have saved myself in case the oproperty is an oresource pointing back to me
            self.save
            if v.is_a? Array
              v = v.map do |val|
                if val.is_a? eval(type.to_s)
                  val
                else
                  eval(type.to_s).first_or_create(val)
                end
              end
            else
              if v.is_a? eval(type.to_s)
                v = [v]
              else
                v = [eval(type.to_s).first_or_create(v)]
              end
            end
          end

          #puts "NAME is '#{name}'"
          #puts "V is '#{v}'"
          oproperty_set(pname, v)
        end


      else
        op[name.to_sym] = opts

        define_method name do
          res = oproperty_get(name)
          if res.nil?
            res = opts[:default]
            if res.nil? && (self.respond_to?(m = "default_#{name}".to_sym))
              res = send(m)
            end
          end
          res
        end

        define_method "#{name}=" do |v|
          if (type.is_a? Symbol) && (!v.nil?)
            # make sure i have saved myself in case the oproperty is an oresource pointing back to me
            self.save
            unless v.is_a? eval(type.to_s)
              v = eval(type.to_s).first_or_create(v)
            end
          end
          oproperty_set(name, v)
        end

      end
    end

    # Clone this resource this resource. However, the clone will have a unique UUID
    #
    def clone()
      clone = self.class.new
      attributes.each do |k, v|
        next if k == :id || k == :uuid
        clone.attribute_set(k, DataMapper::Ext.try_dup(v))
      end
      oproperties.each do |p|
        clone.oproperty_set(p.name, DataMapper::Ext.try_dup(p.value))
      end

      clone.uuid = UUIDTools::UUID.random_create
      return clone
    end

    def uuid()
      unless uuid = attribute_get(:uuid)
        uuid = self.uuid = UUIDTools::UUID.random_create
      end
      uuid
    end

    def href(opts = {})
      if prefix = opts[:name_prefix]
        href = "#{prefix}/#{self.name || self.uuid.to_s}"
      elsif opts[:href_use_class_prefix]
        #href = "/#{self.resource_type}/#{self.name || self.uuid.to_s}"
        href = "/#{self.resource_type.pluralize}/#{self.uuid.to_s}"
      elsif prefix = opts[:href_prefix] || @@default_href_prefix
        href = "#{prefix}/#{self.uuid.to_s}"
      end
      href
    end

    def resource_type()
      unless rt = attribute_get(:resource_type)
        rt = self.class.to_s.split('::')[-1].downcase
      end
      rt
    end


    # Return the status of the resource. Should be
    # one of: _configuring_, _ready_, _failed_, and _unknown_
    #
    def status
      'unknown'
    end

    def oproperty(pname)
      self.oproperties.first(:name => pname.to_sym)
    end


    def oproperty_get(pname)
      #puts "OPROPERTY_GET: pname:'#{pname}'"
      pname = pname.to_sym
      return self.name if pname == :name # relational property

      prop = self.oproperties.first(:name => pname) # gurnaei to property me to sugkekrimeno name (px "valid_until")
      prop.nil? ? nil : prop.value
    end
    alias_method :[], :oproperty_get

    def oproperty_set(pname, value)
      #puts "OPROPERTY_SET pname:'#{pname}', value:'#{value.class}', self:'#{self.inspect}'"
      pname = pname.to_sym
      if pname == :name
        self.name = value
      else
        self.save
        prop = self.oproperties.first_or_create(:name => pname)
        prop.value = value
      end
      value
    end
    alias_method :[]=, :oproperty_set

    def oproperties_as_hash
      res = {}
      oproperties.each do |p|
        res[p.name] = p.value
      end
      res
    end

    def each_resource(&block)
      # resources don't contain other resources, groups do'
    end

    # alias_method :_dirty_children?, :dirty_children?
    # def dirty_children?
    # puts "CHECKING CHILDREN DIRTY: #{_dirty_children?}"
    # _dirty_children?
    # end

    alias_method :_dirty_self?, :dirty_self?
    def dirty_self?
      #puts "CHECKING DIRTY #{_dirty_self?}"
      return true if _dirty_self?
      o_properties.each do |p|
        return true if p.dirty_self?
      end
      false
    end

    # alias_method :_dirty_attributes, :dirty_attributes
    # def dirty_attributes
    # dirty = _dirty_attributes
    # puts "DIRTY ATTRIBUTE #{dirty.inspect}"
    # dirty
    # end

    # Return true if this resource is a Group
    def group?
      false
    end


    # Remove this resource from all groups it currently belongs.
    #
    def remove_from_all_groups
      self.group_memberships.each {|m| m.destroy}
    end

    # Add this resource and all contained to +set+.
    def all_resources(set = Set.new)
      set << self
      set
    end

    def self.resources_to_hash(resource, opts = {}, already_described = {})
      if resource.kind_of? Enumerable
        res = []
        resource.each do |r|
          res << resources_to_hash(r, opts, already_described)
        end
        res = {:resources => res}
      else
        rh = resource.to_hash(already_described, opts)
        already_described[resource] = true
        res = {:resource => rh}
      end
      res
    end

    before :save do
      unless self.resource_type
        self.resource_type = self.class.to_s.split('::')[-1].downcase
      end
      unless self.uuid
        self.uuid = UUIDTools::UUID.random_create
      end
      unless self.name
        self.name = self.urn ? GURN.create(self.urn, :type => self.resource_type).short_name : "r#{self.object_id}"
      end
      #unless self.urn
      #  # The purpose or function of a URN is to provide a globally unique,
      #  # persistent identifier used for recognition, for access to
      #  # characteristics of the resource or for access to the resource
      #  # itself.
      #  # source: http://tools.ietf.org/html/rfc1737
      #  #
      #  name = self.name
      #  self.urn = GURN.create(name, :type => self.resource_type).to_s
      #end
    end

    def destroy
      #debug "ORESOURCE destroy #{self}"
      self.remove_from_all_groups

      #if p = self.provided_by
      #  pa = p.provides
      #  pa.delete self
      #  r = p.save
      #  i = 0
      #end

      # first destroy all properties
      self.oproperties.all().each do |p|
        #debug "ORESOURCE destroying property '#{p.inspect}'"
        r = p.destroy
        r
      end
      #p = self.oproperties.all()
      super
    end

    def destroy!
      #debug "ORESOURCE destroy! #{self}"
      destroy
      super
    end

    def to_json(*a)
      unless self.id
        # need an id, means I haven't been saved yet
        save
      end
      {
        'json_class' => self.class.name,
        'id'       => self.id
      }.to_json(*a)
    end

    def as_json(options = { })
      {
        "json_class" => self.class.name,
        "id" => self.id
      }
    end


    #def self.from_json(o)
    #  puts "FROM_JSON"
    #  klass = o['json_class']
    #  id = o['id']
    #  eval(klass).first(:id => id)
    #end

    def self.json_create(o)
      klass = o['json_class']
      id = o['id']
      r = eval(klass).first(:id => id)
      r
    end

    def to_hash(objs = {}, opts = {})
      #debug "to_hash(self):opts: #{opts.keys.inspect}::#{objs.keys.inspect}::"
      h = to_hash_brief(opts)

      return h if objs.key?(self)
      objs[self] = true
      return h if opts[:brief]

      if max_levels = opts[:max_levels]
        level = (opts[:level] || 0) + 1
        opts = opts.merge(level: level)
        opts[:brief] = true if level > max_levels
      else
        opts = opts.merge(brief: true)
      end
      #puts ">>>> #{opts}"
      to_hash_long(h, objs, opts)
      h
    end

    def to_hash_brief(opts = {})
      h = {}
      uuid = h[:uuid] = self.uuid.to_s
      h[:urn] = self.urn.to_s unless self.urn.nil?
      h[:href] = self.href(opts)
      name = self.name
      if  name && ! name.start_with?('_')
        h[:name] = self.name
        h[:account] = self.account.to_hash_brief(opts) unless self.account.nil? || self.is_a?(OMF::SFA::Resource::Account)
      end
      h[:type] = self.resource_type
      h
    end

    def to_hash_long(h, objs = {}, opts = {})
      _oprops_to_hash(h, objs, opts)
      h
    end

    def default_href_prefix
      @@default_href_prefix
    end

    def _oprops_to_hash(h, objs, opts)
      klass = self.class
      while klass
        if op = @@oprops[klass]
          op.each do |k, v|
            k = k.to_sym
            next if k == :provides
            unless (value = send(k)).nil?
              #puts "OPROPS_TO_HAHS(#{k}): #{value}::#{value.class}--#{oproperty_get(k)}"
              if value.is_a? OResource
                value = value.to_hash(objs, opts)
              end
              if value.is_a? Time
                value = value.iso8601
              end
              if value.kind_of? Array
                next if value.empty?
                value = value.collect do |e|
                  (e.kind_of? OResource) ? e.to_hash(objs, opts) : e
                end
              end

              h[k] = value
            end
          end
        end
        klass = klass.superclass
      end
      h
    end
  end

  # Extend array to add functionality dealing with property values
  #class PropValueArray < Array

  #  def to_json(*a)
  #    {
  #      'json_class' => self.class.name,
  #      'els' => self.to_a.to_json
  #    }.to_json(*a)
  #  end

  #  def self.json_create(o)
  #    # http://www.ruby-lang.org/en/news/2013/02/22/json-dos-cve-2013-0269/
  #    v = JSON.load(o['els'])
  #    v
  #  end

  #end

end # OMF::SFA

