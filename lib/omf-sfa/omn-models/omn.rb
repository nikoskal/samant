require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic

  # Preload ontology
  Omn = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn#")
  OmnLifecycle = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-lifecycle#")
  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class Attribute < Spira::Base
    configure :base_uri => Omn.Attribute
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Attribute')

    # Object Properties

    has_many :isAttributeOf, :predicate => Omn.isAttributeOf

    # Data Properties

    property :isReadonly, :predicate => Omn.isReadonly, :type => Boolean

  end

  class Component < Spira::Base
    configure :base_uri => Omn.Component
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Component')

    # Object Properties

    has_many :adaptsFrom, :predicate => Omn.adaptsFrom
    has_many :adaptsTo, :predicate => Omn.adaptsTo
    has_many :dependsOn, :predicate => Omn.dependsOn
    has_many :hasAttribute, :predicate => Omn.hasAttribute, :type => :Attribute
    has_many :hasComponent, :predicate => Omn.hasComponent, :type => :Component
    has_many :isComponentOf, :predicate => Omn.isComponentOf
    has_many :relatesTo, :predicate => Omn.relatesTo

    # Data Properties

    property :hasComponentID, :predicate => OmnLifecycle.hasComponentID, :type => URI
    property :hasComponentManagerID, :predicate => OmnLifecycle.hasComponentManagerID, :type => URI
    property :hasComponentManagerName, :predicate => OmnLifecycle.hasComponentManagerName, :type => URI
    property :hasComponentName, :predicate => OmnLifecycle.hasComponentName, :type => String

  end

  class ReservationState < Attribute
    configure :base_uri => OmnLifecycle.ReservationState
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#ReservationState')

    # Object Properties

    has_many :isReservationStateOf, :predicate => OmnLifecycle.isReservationStateOf, :type => :Reservation

  end

  class State < Attribute
    configure :base_uri => OmnLifecycle.State
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#State')

    # Object Properties

    property :hasAction, :predicate => OmnLifecycle.hasAction, :type => :Action
    property :hasNext, :predicate => OmnLifecycle.hasNext, :type => :State
    property :hasStateName, :predicate => OmnLifecycle.hasStateName, :type => :State
    property :hasType, :predicate => OmnLifecycle.hasType, :type => :State
    has_many :hasWait, :predicate => OmnLifecycle.hasWait, :type => :Wait
    has_many :isStateOf, :predicate => OmnLifecycle.isStateOf, :type => :LifecycleUnion

  end

  class LifecycleUnion < Spira::Base
    configure :base_uri => OmnLifecycle
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#')

    # Object Properties

    has_many :canBeImplementedBy, :predicate => OmnLifecycle.canBeImplementedBy, :type => :LifecycleUnion
    has_many :canImplement, :predicate => OmnLifecycle.canImplement, :type => :LifecycleUnion
    has_many :childOf , :predicate => OmnLifecycle.childOf, :type => :LifecycleUnion
    property :hasState , :predicate => OmnLifecycle.hasState, :type => :State
    has_many :implementedBy, :predicate => OmnLifecycle.implementedBy, :type => :LifecycleUnion
    has_many :implements, :predicate => OmnLifecycle.implements, :type => :LifecycleUnion
    has_many :parentOf, :predicate => OmnLifecycle.parentOf, :type => :LifecycleUnion
    has_many :usesService, :predicate => OmnLifecycle.usesService, :type => :Service

  end

  class Group < LifecycleUnion
    configure :base_uri => Omn.Group
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Group')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service
    has_many :adaptsFrom, :predicate => Omn.adaptsFrom
    has_many :adaptsTo, :predicate => Omn.adaptsTo
    has_many :dependsOn, :predicate => Omn.dependsOn
    has_many :hasAttribute, :predicate => Omn.hasAttribute, :type => :Attribute
    has_many :hasGroup, :predicate => Omn.hasGroup, :type => :Group
    has_many :hasReservation, :predicate => Omn.hasReservation, :type => :Reservation
    has_many :hasResource, :predicate => Omn.hasResource #, :type => :Resource
    has_many :hasService, :predicate => Omn.hasService, :type => :Service
    has_many :isGroupOf, :predicate => Omn.isGroupOf, :type => :Group
    has_many :relatesTo, :predicate => Omn.relatesTo

    # Data Properties

    property :expirationTime, :predicate => OmnLifecycle.expirationTime, :type => DateTime
    property :hasURI, :predicate => Omn.hasURI, :type => URI

  end

  class Reservation < LifecycleUnion
    configure :base_uri => Omn.Reservation
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Reservation')

    # Object Properties

    has_many :hasReservationState, :predicate => OmnLifecycle.hasReservationState, :type => :ReservationState
    has_many :isReservationOf, :predicate => Omn.isReservationOf, :type => :NetworkObject

    # Data Properties

    property :hasID, :predicate => OmnLifecycle.hasID, :type => String
    property :hasIdRef, :predicate => OmnLifecycle.hasIdRef, :type => String
    property :hasSliceID, :predicate => OmnLifecycle.hasSliceID, :type => String

    # Exoun mpei proswrina mexri na vroume ti paizei
    property :expirationTime, :predicate => OmnLifecycle.expirationTime, :type => DateTime
    property :startTime, :predicate => OmnLifecycle.startTime, :type => DateTime

  end

  class Resource < Spira::Base
    configure :base_uri => Omn.Resource
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Resource')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service
    has_many :adaptsFrom, :predicate => Omn.adaptsFrom
    has_many :adaptsTo, :predicate => Omn.adaptsTo
    has_many :dependsOn, :predicate => Omn.dependsOn
    has_many :hasAttribute, :predicate => Omn.hasAttribute, :type => :Attribute
    has_many :hasComponent, :predicate => Omn.hasComponent, :type => :Component
    has_many :hasReservation, :predicate => Omn.hasReservation, :type => :Reservation
    has_many :hasService, :predicate => Omn.hasService, :type => :Service
    has_many :isResourceOf, :predicate => Omn.isResourceOf, :type => :Group
    has_many :relatesTo, :predicate => Omn.relatesTo

    # Data Properties

    property :creationTime, :predicate => OmnLifecycle.creationTime, :type => DateTime
    property :creator, :predicate => OmnLifecycle.creator, :type => String
    property :expirationTime, :predicate => OmnLifecycle.expirationTime, :type => DateTime
    property :hasAuthenticationInformation, :predicate => OmnLifecycle.hasAuthenticationInformation, :type => String
    property :hasComponentID, :predicate => OmnLifecycle.hasComponentID, :type => URI
    property :hasComponentManagerID, :predicate => OmnLifecycle.hasComponentManagerID, :type => URI
    property :hasComponentManagerName, :predicate => OmnLifecycle.hasComponentManagerName, :type => URI
    property :hasComponentName, :predicate => OmnLifecycle.hasComponentName, :type => String
    property :hasID, :predicate => OmnLifecycle.hasID, :type => String
    property :hasIdRef, :predicate => OmnLifecycle.hasIdRef, :type => String
    property :hasOriginalID, :predicate => OmnLifecycle.hasOriginalID, :type => String
    property :resourceId, :predicate => OmnLifecycle.resourceId, :type => String
    property :hasRole, :predicate => OmnLifecycle.hasRole, :type => String
    property :hasSliverID, :predicate => OmnLifecycle.hasSliverID, :type => String
    property :hasSliceID, :predicate => OmnLifecycle.hasSliceID, :type => String
    property :hasSliverName, :predicate => OmnLifecycle.hasSliverName, :type => String
    property :startTime, :predicate => OmnLifecycle.startTime, :type => DateTime
    property :hasURI, :predicate => Omn.hasURI, :type => URI
    property :isVirtualized, :predicate => Omn.isVirtualized, :type => Boolean

  end

  class Service < LifecycleUnion
    configure :base_uri => Omn.Service
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Service')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :serviceIsUsedBy, :predicate => OmnLifecycle.serviceIsUsedBy, :type => :LifecycleUnion
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service
    has_many :adaptsFrom, :predicate => Omn.adaptsFrom
    has_many :adaptsTo, :predicate => Omn.adaptsTo
    has_many :dependsOn, :predicate => Omn.dependsOn
    has_many :hasAttribute, :predicate => Omn.hasAttribute, :type => :Attribute
    has_many :hasComponent, :predicate => Omn.hasComponent, :type => :Component
    has_many :hasReservation, :predicate => Omn.hasReservation, :type => :Reservation
    has_many :isServiceOf, :predicate => Omn.isServiceOf
    has_many :relatesTo, :predicate => Omn.relatesTo

    # Data Properties

    property :creationTime, :predicate => OmnLifecycle.creationTime, :type => DateTime
    property :creator, :predicate => OmnLifecycle.creator, :type => String
    property :expirationTime, :predicate => OmnLifecycle.expirationTime, :type => DateTime
    property :hasAuthenticationInformation, :predicate => OmnLifecycle.hasAuthenticationInformation, :type => String
    property :hasComponentID, :predicate => OmnLifecycle.hasComponentID, :type => URI
    property :hasComponentManagerID, :predicate => OmnLifecycle.hasComponentManagerID, :type => URI
    property :hasComponentManagerName, :predicate => OmnLifecycle.hasComponentManagerName, :type => URI
    property :hasComponentName, :predicate => OmnLifecycle.hasComponentName, :type => String
    property :hasID, :predicate => OmnLifecycle.hasID, :type => String
    property :hasIdRef, :predicate => OmnLifecycle.hasIdRef, :type => String
    property :hasOriginalID, :predicate => OmnLifecycle.hasOriginalID, :type => String
    property :resourceId, :predicate => OmnLifecycle.resourceId, :type => String
    property :hasRole, :predicate => OmnLifecycle.hasRole, :type => String
    property :hasSliverID, :predicate => OmnLifecycle.hasSliverID, :type => String
    property :hasSliceID, :predicate => OmnLifecycle.hasSliceID, :type => String
    property :hasSliverName, :predicate => OmnLifecycle.hasSliverName, :type => String
    property :startTime, :predicate => OmnLifecycle.startTime, :type => DateTime
    property :hasEndpoint, :predicate => Omn.hasEndpoint, :type => URI
    property :hasURI, :predicate => Omn.hasURI, :type => URI

  end

  class Topology < LifecycleUnion
    configure :base_uri => Omn.Topology
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Topology')

    # Data Properties

    property :project, :predicate => OmnLifecycle.project, :type => String

  end

end