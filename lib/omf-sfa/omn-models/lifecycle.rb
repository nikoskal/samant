require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic

  # Preload ontology
  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  #exw metaferei polla apo Lifecycle stin OMN

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