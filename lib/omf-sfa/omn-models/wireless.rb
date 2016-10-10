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

  class DecimalPrefix < Spira::Base #ELABORATE
    configure :base_uri => OmnMonitoringUnit
    type RDF::URI.new('http://open-multinet.info/ontology/omn-monitoring-unit#')
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



end
