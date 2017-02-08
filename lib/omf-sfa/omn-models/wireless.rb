require 'spira'
require 'rdf/turtle'
require 'rdf/json'
require 'sparql/client'
#require 'sparql'

module Semantic

  # Preload ontology
  OmnWireless = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn_wireless.owl#")
  OmnMonitoringUnit = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-monitoring-unit#")
  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class Prefix < Spira::Base #ELABORATE
    configure :base_uri => OmnMonitoringUnit.Prefix
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#Prefix')
  end

  class Feature < Spira::Base
    configure :base_uri => OmnWireless.Feature
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#Feature')
  end

  class Location < Spira::Base
    configure :base_uri => OmnWireless.Location
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#Location')
  end

  class DecimalPrefix < Prefix
    configure :base_uri => OmnMonitoringUnit.DecimalPrefix
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#DecimalPrefix')
  end

  class Antenna < Feature
    configure :base_uri => OmnWireless.Antenna
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#Antenna')
  end

  class AntennaBandSupport < Feature
    configure :base_uri => OmnWireless.AntennaBandSupport
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#AntennaBandSupport')
  end

  class AntennaType < Feature
    configure :base_uri => OmnWireless.AntennaType
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#AntennaType')
  end

  class Channel < Component
    configure :base_uri => OmnWireless.Channel
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#Channel')
  end

  #class Frequency < Feature
  #  configure :base_uri => OmnWireless.Frequency
  #  type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#Frequency')
  #end

  class MicroController < Component
    configure :base_uri => OmnWireless.MicroController
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#MicroController')
  end

  class Sensor < Component
    configure :base_uri => OmnWireless.Sensor
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#Sensor')
  end

  class SensorModule < Component
    configure :base_uri => OmnWireless.SensorModule
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#SensorModule')
  end

  class Standard < Feature
    configure :base_uri => OmnWireless.Standard
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#Standard')
  end

  class WiredInterface < Interface
    configure :base_uri => OmnWireless.WiredInterface
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#WiredInterface')
  end

  class WirelessInterface < Interface
    configure :base_uri => OmnWireless.WirelessInterface
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#WirelessInterface')

    # Object Properties

    has_many :hasAntenna, :predicate => OmnWireless.hasAntenna, :type => :Antenna
    has_many :hasAntennaBandSupport, :predicate => OmnWireless.hasAntennaBandSupport, :type => :AntennaBandSupport

  end

  class XyzCartesianCoordinate < Location
    configure :base_uri => OmnWireless.XyzCartesianCoordinate
    type RDF::URI.new('http://open-multinet.info/ontology/omn_wireless.owl#xyzCartesianCoordinate')
  end

end
