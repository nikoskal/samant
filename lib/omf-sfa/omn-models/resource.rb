require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic
  # Preload ontology

  OmnResource = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-resource#")

  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class Resource < Spira::Base
    configure :base_uri => OmnResource
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#')

    # Object Properties

    has_many :interfaces, :predicate => OmnResource.hasInterface, :type => :Interface
    has_many :ips, :predicate => OmnResource.hasIPAddress, :type => :NetworkObject
    has_many :sinks, :predicate => OmnResource.hasSink, :type => :Interface
    has_many :sources, :predicate => OmnResource.hasSource, :type => :Interface
    has_many :properties, :predicate => OmnResource.hasProperty, :type => :Link
    has_many :requires, :predicate => OmnResource.requires, :type => :NetworkObject
    property :interfaceOf, :predicate => OmnResource.isInterfaceOf, :type => :NetworkObject # TODO how to implement group ranges? / multitypes?
    property :ipOf,  :predicate => OmnResource.isIPAddressOf, :type => :NetworkObject
    property :location, :predicate => OmnResource.hasLocation, :type => :Location
    property :sinkOf, :predicate => OmnResource.isSink, :type => :Link
    property :sourceOf, :predicate => OmnResource.isSource, :type => :Link
    property :sliverType, :predicate => OmnResource.hasSliverType, :type => :SliverType
    property :propertyOf, :predicate => OmnResource.isPropertyOf, :type => :LinkProperty
    property :requiredBy, :predicate => OmnResource.requiredBy, :type => :NetworkObject
    property :hardwareType, :predicate => OmnResource.hasHardwareType, :type => :HardwareType # @omn-domain-pc TODO implementation
    property :hardwareTypeOf, :predicate => OmnResource.isHardwareTypeOf, :type => :NetworkObject

    property :managedBy, :predicate => OmnResource.managedBy, :type => :Account # TODO insert to OMN ONTOLOGY

    # Data Properties

    property :address, :predicate => OmnResource.address, :type => String
    property :clientId, :predicate => OmnResource.clientId, :type => String
    property :available, :predicate => OmnResource.isAvailable, :type => Boolean
    property :exclusive, :predicate => OmnResource.isExclusive, :type => Boolean
    property :jfedX, :predicate => OmnResource.jfedX, :type => String
    property :jfedY, :predicate => OmnResource.jfedY, :type => String
    property :x, :predicate => OmnResource.x, :type => Decimal
    property :y, :predicate => OmnResource.y, :type => Decimal
    property :z, :predicate => OmnResource.z, :type => Decimal
    property :macAddress, :predicate => OmnResource.macAddress, :type => String
    property :netmask, :predicate => OmnResource.netmask, :type => String
    property :port, :predicate => OmnResource.port, :type => Integer
    property :type, :predicate => OmnResource.type, :type => String

    # validates :interfaceOf, :type => :NetworkObject # TODO validations?

    def self.to_turtle(query)
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
      ::JSON.pretty_generate(res) # apo merged hash se JSON
    end

  end

  class NetworkObject < Resource
    configure :base_uri => OmnResource.NetworkObject
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#NetworkObject')
  end

  class Node < NetworkObject
    configure :base_uri => OmnResource.Node
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Node')
  end

  class Openflow < NetworkObject
    configure :base_uri => OmnResource.Openflow
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Openflow')
  end

  class Interface < NetworkObject
    configure :base_uri => OmnResource.Interface
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Interface')
  end

  class Location < Resource
    configure :base_uri => OmnResource.Location
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Location')
  end

  class Cloud < NetworkObject
    configure :base_uri => OmnResource.Cloud
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Cloud')
  end

  class Hop < NetworkObject
    configure :base_uri => OmnResource.Hop
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Hop')
  end

  class IPAddress < Resource
    configure :base_uri => OmnResource.IPAddress
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#IPAddress')
  end

  class Link < Resource
    configure :base_uri => OmnResource.Link
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Link')
  end

  class LinkProperty < Resource
    configure :base_uri => OmnResource.LinkProperty
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#LinkProperty')
  end

  class Path < NetworkObject
    configure :base_uri => OmnResource.Path
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Path')
  end

  class SliverType < NetworkObject
    configure :base_uri => OmnResource.SliverType
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#SliverType')
  end

  class Stitching < NetworkObject
    configure :base_uri => OmnResource.Stitching
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Stitching')
  end

end
