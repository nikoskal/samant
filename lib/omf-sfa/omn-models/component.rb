require 'spira'

module Semantic

  # Preload ontology

  OmnComponent = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-component#")

  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class OmnComponent < Spira::Base
    configure :base_uri => OmnComponent
    type RDF::URI.new('http://open-multinet.info/ontology/omn-component#')

    # Data Properties

    property :cores, :predicate => OmnComponent.hasCores, :type => Integer
    property :model, :predicate => OmnComponent.hasModelType, :type => String

  end

  class Cpu < OmnComponent
    configure :base_uri => OmnComponent.CPU
    type RDF::URI.new('http://open-multinet.info/ontology/omn-component#CPU')
  end

  class MemoryComponent < OmnComponent
    configure :base_uri => OmnComponent.MemoryComponent
    type RDF::URI.new('http://open-multinet.info/ontology/omn-component#MemoryComponent')
  end

  class ProcessingComponent < OmnComponent
    configure :base_uri => OmnComponent.ProcessingComponent
    type RDF::URI.new('http://open-multinet.info/ontology/omn-component#ProcessingComponent')
  end

  class StorageComponent < OmnComponent
    configure :base_uri => OmnComponent.StorageComponent
    type RDF::URI.new('http://open-multinet.info/ontology/omn-component#StorageComponent')
  end

end