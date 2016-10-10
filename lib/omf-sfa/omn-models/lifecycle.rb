require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic

  # Preload ontology
  OmnLifecycle = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-lifecycle#")
  Omn = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn#")
  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class Union1 < Spira::Base
    configure :base_uri => OmnLifecycle
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#')

    # Object Properties

    has_many :canBeImplementedBy, :predicate => OmnLifecycle.canBeImplementedBy, :type => :Union1
    has_many :canImplement, :predicate => OmnLifecycle.canImplement, :type => :Union1
    has_many :childOf , :predicate => OmnLifecycle.childOf, :type => :Union1
    has_many :hasState , :predicate => OmnLifecycle.hasState, :type => :State
    has_many :implementedBy, :predicate => OmnLifecycle.implementedBy, :type => :Union1
    has_many :implements, :predicate => OmnLifecycle.implements, :type => :Union1
    has_many :parentOf, :predicate => OmnLifecycle.parentOf, :type => :Union1
    has_many :usesService, :predicate => OmnLifecycle.usesService, :type => :Service

    # Data Properties


  end

  class Attribute < Spira::Base
    configure :base_uri => Omn.Attribute
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Attribute')
  end

  class Component < Spira::Base
    configure :base_uri => Omn.Component
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Component')

    # Data Properties

    property :hasComponentID, :predicate => OmnLifecycle.hasComponentID, :type => URI
    property :hasComponentManagerID, :predicate => OmnLifecycle.hasComponentManagerID, :type => URI
    property :hasComponentManagerName, :predicate => OmnLifecycle.hasComponentManagerName, :type => URI
    property :hasComponentName, :predicate => OmnLifecycle.hasComponentName, :type => String

  end

  class Group < Union1
    configure :base_uri => Omn.Group
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Group')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service

    # Data Properties

    property :expirationTime, :predicate => OmnLifecycle.expirationTime, :type => DateTime

  end

  class Reservation < Union1
    configure :base_uri => Omn.Reservation
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Reservation')

    # Object Properties

    has_many :hasReservationState, :predicate => OmnLifecycle.hasReservationState, :type => :ReservationState

    # Data Properties

    property :hasID, :predicate => OmnLifecycle.hasID, :type => String
    property :hasIdRef, :predicate => OmnLifecycle.hasIdRef, :type => String
    property :hasSliceID, :predicate => OmnLifecycle.hasSliceID, :type => String

  end

  class Resource < Spira::Base
    configure :base_uri => Omn.Resource
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Resource')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service

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

  end

  class Service < Union1
    configure :base_uri => Omn.Service
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Service')

    # Object Properties

    has_many :hasLease, :predicate => OmnLifecycle.hasLease, :type => :Lease
    has_many :serviceIsUsedBy, :predicate => OmnLifecycle.serviceIsUsedBy, :type => :Union1
    has_many :managedBy, :predicate => OmnLifecycle.managedBy, :type => :Service

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

  end

  class Topology < Union1
    configure :base_uri => Omn.Topology
    type RDF::URI.new('http://open-multinet.info/ontology/omn#Topology')

    # Data Properties

    property :project, :predicate => OmnLifecycle.project, :type => String

  end

  class Action < State
    configure :base_uri => OmnLifecycle.Action
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Action')
  end

  class Active < State
    configure :base_uri => OmnLifecycle.Active
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Active')
  end

  class Allocated < ReservationState
    configure :base_uri => OmnLifecycle.Allocated
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Allocated')
  end

  class Cleaned < State
    configure :base_uri => OmnLifecycle.Cleaned
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Cleaned')
  end

  class Confirmation < Topology
    configure :base_uri => OmnLifecycle.Confirmation
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Confirmation')
  end

  class Error < State
    configure :base_uri => OmnLifecycle.Error
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Error')
  end

  class Failure < State
    configure :base_uri => OmnLifecycle.Failure
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Failure')
  end

  class Initialized < State
    configure :base_uri => OmnLifecycle.Initialized
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Initialized')
  end

  class Installed < State
    configure :base_uri => OmnLifecycle.Installed
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Installed')
  end

  class Lease < Reservation
    configure :base_uri => OmnLifecycle.Lease
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Lease')
  end

  class Manifest < Topology
    configure :base_uri => OmnLifecycle.Manifest
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Manifest')
  end

  class Nascent < State
    configure :base_uri => OmnLifecycle.Nascent
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Nascent')
  end

  class NotReady < State
    configure :base_uri => OmnLifecycle.NotReady
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#NotReady')
  end

  class NotYetInitialized < State
    configure :base_uri => OmnLifecycle.NotYetInitialized
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#NotYetInitialized')
  end

  class Offering < Topology
    configure :base_uri => OmnLifecycle.Offering
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Offering')
  end

  class Opstate < Resource
    configure :base_uri => OmnLifecycle.Opstate
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Opstate')

    # Object Properties

    has_many :hasStartState, :predicate => OmnLifecycle.hasStartState, :type => :State

  end

  class Pending < State
    configure :base_uri => OmnLifecycle.Pending
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Pending')
  end

  class Preinit < State
    configure :base_uri => OmnLifecycle.Preinit
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Preinit')
  end

  class Unknown < State
    configure :base_uri => OmnLifecycle.Unknown
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Unknown')
  end

  class Provisioned < State
    configure :base_uri => OmnLifecycle.Provisioned
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Provisioned')
  end

  class Ready < State
    configure :base_uri => OmnLifecycle.Ready
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Ready')
  end

  class Removing < State
    configure :base_uri => OmnLifecycle.Removing
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Removing')
  end

  class Request < Topology
    configure :base_uri => OmnLifecycle.Request
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Request')
  end

  class ReservationState < Attribute
    configure :base_uri => OmnLifecycle.ReservationState
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#ReservationState')

    # Object Properties

    has_many :isReservationStateOf, :predicate => OmnLifecycle.isReservationStateOf, :type => :Reservation

  end

  class Success < State
    configure :base_uri => OmnLifecycle.Success
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Success')
  end

  class Restart < State
    configure :base_uri => OmnLifecycle.Restart
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Restart')
  end

  class Start < State
    configure :base_uri => OmnLifecycle.Start
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Start')
  end

  class Started < State
    configure :base_uri => OmnLifecycle.Started
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Started')
  end

  class State < Attribute
    configure :base_uri => OmnLifecycle.State
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#State')

    # Object Properties

    has_many :hasAction, :predicate => OmnLifecycle.hasAction, :type => :Action
    has_many :hasNext, :predicate => OmnLifecycle.hasNext, :type => :State
    has_many :hasStateName, :predicate => OmnLifecycle.hasStateName, :type => :State
    has_many :hasType, :predicate => OmnLifecycle.hasType, :type => :State
    has_many :hasWait, :predicate => OmnLifecycle.hasWait, :type => :Wait
    has_many :isStateOf, :predicate => OmnLifecycle.isStateOf, :type => :Union1

  end

  class Stop < State
    configure :base_uri => OmnLifecycle.Stop
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Stop')
  end

  class Stopped < State
    configure :base_uri => OmnLifecycle.Stopped
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Stopped')
  end

  class Stopping < State
    configure :base_uri => OmnLifecycle.Stopping
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Stopping')
  end

  class Unallocated < ReservationState
    configure :base_uri => OmnLifecycle.Unallocated
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Unallocated')
  end

  class Reload < State
    configure :base_uri => OmnLifecycle.Reload
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Reload')
  end

  class UpdatingUsers < State
    configure :base_uri => OmnLifecycle.UpdatingUsers
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#UpdatingUsers')
  end

  class UpdateUsersCancel < State
    configure :base_uri => OmnLifecycle.UpdateUsersCancel
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#UpdateUsersCancel')
  end

  class UpdateUsers < State
    configure :base_uri => OmnLifecycle.UpdateUsers
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#UpdateUsers')
  end

  class Uncompleted < State
    configure :base_uri => OmnLifecycle.Uncompleted
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Uncompleted')
  end

  class Updating < State
    configure :base_uri => OmnLifecycle.Updating
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Updating')
  end

  class Wait < State
    configure :base_uri => OmnLifecycle.Wait
    type RDF::URI.new('http://open-multinet.info/ontology/omn-lifecycle#Wait')
  end

end