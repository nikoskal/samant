require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic
  # Preload ontology

  # exw allaksei Resource se OResource

  OmnResource = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-resource#")

  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class OResource < Spira::Base
    configure :base_uri => OmnResource
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#')

    # Object Properties

    has_many :hasInterface, :predicate => OmnResource.hasInterface, :type => :Interface
    property :hasLocation, :predicate => OmnResource.hasLocation, :type => :Location
    property :hasHardwareType, :predicate => OmnResource.hasHardwareType, :type => :HardwareType # @omn-domain-pc TODO implementation
    property :isHardwareTypeOf, :predicate => OmnResource.isHardwareTypeOf, :type => :NetworkObject

    # Data Properties

    property :isExclusive, :predicate => OmnResource.isExclusive, :type => Boolean

    # validates :interfaceOf, :type => :NetworkObject # TODO validations?

  end

  class NetworkObject < OResource
    configure :base_uri => OmnResource.NetworkObject
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#NetworkObject')

    # Object Properties

    has_many :hasIPAddress, :predicate => OmnResource.hasIPAddress, :type => :IPAddress
    property :hasSliverType, :predicate => OmnResource.hasSliverType, :type => :SliverType
    property :requiredBy, :predicate => OmnResource.requiredBy, :type => :NetworkObject
    has_many :requires, :predicate => OmnResource.requires, :type => :NetworkObject

    # Data Properties

    property :isAvailable, :predicate => OmnResource.isAvailable, :type => Boolean

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

    # Object Properties

    property :isInterfaceOf, :predicate => OmnResource.isInterfaceOf, :type => :NetworkObject # TODO how to implement group ranges? / multitypes?
    property :isSink, :predicate => OmnResource.isSink, :type => :Link
    property :isSource, :predicate => OmnResource.isSource, :type => :Link

    # Data Properties

    property :clientId, :predicate => OmnResource.clientId, :type => String
    property :macAddress, :predicate => OmnResource.macAddress, :type => String
    property :port, :predicate => OmnResource.port, :type => Integer

  end

  class Location < Spira::Base
    configure :base_uri => OmnResource.Location
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Location')

    # Data Properties

    property :jfedX, :predicate => OmnResource.jfedX, :type => String
    property :jfedY, :predicate => OmnResource.jfedY, :type => String
    property :x, :predicate => OmnResource.x, :type => Decimal
    property :y, :predicate => OmnResource.y, :type => Decimal
    property :z, :predicate => OmnResource.z, :type => Decimal

  end

  class Cloud < NetworkObject
    configure :base_uri => OmnResource.Cloud
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Cloud')
  end

  class Hop < NetworkObject
    configure :base_uri => OmnResource.Hop
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Hop')
  end

  class IPAddress < OResource
    configure :base_uri => OmnResource.IPAddress
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#IPAddress')

    # Object Properties

    property :isIPAddressOf,  :predicate => OmnResource.isIPAddressOf, :type => :NetworkObject

    # Data Properties

    property :address, :predicate => OmnResource.address, :type => String
    property :netmask, :predicate => OmnResource.netmask, :type => String
    property :type, :predicate => OmnResource.type, :type => String


  end

  class Link < OResource
    configure :base_uri => OmnResource.Link
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#Link')

    # Object Properties

    has_many :hasSink, :predicate => OmnResource.hasSink, :type => :Interface
    has_many :hasSource, :predicate => OmnResource.hasSource, :type => :Interface
    property :isPropertyOf, :predicate => OmnResource.isPropertyOf, :type => :LinkProperty

  end

  class LinkProperty < OResource
    configure :base_uri => OmnResource.LinkProperty
    type RDF::URI.new('http://open-multinet.info/ontology/omn-resource#LinkProperty')

    # Object Properties

    has_many :hasProperty, :predicate => OmnResource.hasProperty, :type => :Link

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
