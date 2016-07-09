require 'spira'

module Semantic

  # Preload ontology

  DAO = RDF::Vocabulary.new("http://www.semanticdesktop.org/ontologies/2011/10/05/dao/#") #  Digital.Me Account Ontology


  # Built in vocabs: OWL, RDF, RDFS

  ##### CLASSES #####

  class Account < Spira::Base
    configure :base_uri => DAO.Account
    type RDF::URI.new('http://www.semanticdesktop.org/ontologies/2011/10/05/dao/#Account')

    # Data Properties

    property :type, :predicate => DAO.accountType, :type => String

    # Object Properties

    property :credentials, :predicate => DAO.hasCredentials, :type => :Credentials

  end

  class Credentials < Spira::Base
    configure :base_uri => DAO.Credentials
    type RDF::URI.new('http://www.semanticdesktop.org/ontologies/2011/10/05/dao/#Credentials')

    # Data Properties

    property :password, :predicate => DAO.password, :type => String
    property :id, :predicate => DAO.userID, :type => String

  end

end