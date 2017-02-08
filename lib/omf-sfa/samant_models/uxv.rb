require_relative 'anyURItype.rb' # Custom XSD.anyURI type, missing from Spira Implementation

module SAMANT

  # TODO module SAMANT to SAMANT::Model

  # Ontology Namespaces (prefixes)
  # Built in vocabs: OWL, RDF, RDFS

  OMNupper = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn#")
  OMNresource = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-resource#")
  OMNlifecycle = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-lifecycle#")
  OMNfederation = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-federation#")
  OMNwireless = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-federation#")
  SAMANTuxv = RDF::Vocabulary.new("http://open-multinet.info/ontology/omn-domain-wireless#")
  FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
  GML = RDF::Vocabulary.new("http://www.opengis.net/gml/")
  GEO = RDF::Vocabulary.new("http://www.georss.org/georss/")
  GEO2003 = RDF::Vocabulary.new("http://www.w3.org/2003/01/geo/wgs84_pos#")

  ##### CLASSES #####

  class Geometry < Spira::Base
    # TODO base_uri needs an underscore
    configure :base_uri => GML._Geometry
    type RDF::URI.new("http://www.opengis.net/gml/_Geometry")
  end

  class Channel < Spira::Base
    # Imported from omn-domain-wireless:Channel
    configure :base_uri => OMNwireless.Channel
    type RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#Channel")
    # Object Properties
    property :supportsStandard, :predicate => OMNwireless.supportsStandard, :type => :Standard
    property :usesFrequency, :predicate => OMNwireless.usesFrequency, :type => :Frequency
    # Data Properties
    property :channelNum, :predicate => OMNwireless.channelNum, :type => RDF::XSD.integer
  end

  class OFrequency < Spira::Base
    # Imported from omn-domain-wireless:Frequency
    configure :base_uri => OMNwireless.Frequency
    type RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#Frequency")
    # Data Properties
    property :lowerBoundFrequency, :predicate => OMNwireless.lowerBoundFrequency, :type => RDF::XSD.integer
    property :upperBoundFrequency, :predicate => OMNwireless.upperBoundFrequency, :type => RDF::XSD.integer
  end

  class Standard < Spira::Base
    # Imported from omn-domain-wireless:Standard
    configure :base_uri => OMNwireless.Standard
    type RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#Standard")
  end

  class Size < Spira::Base
    configure :base_uri => SAMANTuxv.Size
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Size")
  end

  class Reservation < Spira::Base
    # Imported from omn:Reservation
    configure :base_uri => OMNupper.Reservation
    type RDF::URI.new("http://open-multinet.info/ontology/omn#Reservation")
  end

  class Interface < Spira::Base
    # Imported from omn-resource:Interface
    configure :base_uri => OMNresource.Interface
    type RDF::URI.new("http://open-multinet.info/ontology/omn-resource#Interface")
    # Object Properties
    property :hasComponent, :predicate => OMNresource.hasComponent, :type => :Channel
    property :isInterfaceOf, :predicate => OMNresource.isInterfaceOf, :type => :UxV
    # Data Properties
    property :hasID, :predicate => OMNlifecycle.hasID, :type => String
    property :hasComponentName, :predicate => OMNlifecycle.hasComponentName, :type => RDF::XSD.string
    property :hasComponentID, :predicate => OMNlifecycle.hasComponentID, :type => XSD.anyURI
    property :hasRole, :predicate => OMNlifecycle.hasRole, :type => String
  end

  class ReservationState < Spira::Base
    # Imported from omn-lifecycle:ReservationState
    configure :base_uri => OMNlifecycle.ReservationState
    type RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#ReservationState")
  end

  class Resource < Spira::Base
    # Imported from omn:Reservation
    configure :base_uri => OMNupper.Resource
    type RDF::URI.new("http://open-multinet.info/ontology/omn#Resource")
  end

  class Infrastructure < Spira::Base
    # Imported by omn-federation:Infrastructure
    configure :base_uri => OMNfederation.Infrastructure
    type RDF::URI.new("http://open-multinet.info/ontology/omn-federation#Infrastructure")
  end

  class HealthStatus < Spira::Base
    configure :base_uri => SAMANTuxv.HealthStatus
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#HealthStatus")
    # Object Properties
    property :isHealthStatusOf, :predicate => SAMANTuxv.isHealthStatusOf, :type => :UxV
    property :isHealthStatusOf, :predicate => SAMANTuxv.isHealthStatusOf, :type => :TestBed
    property :isHealthStatusOf, :predicate => SAMANTuxv.isHealthStatusOf, :type => :SensingDevice
    property :isHealthStatusOf, :predicate => SAMANTuxv.isHealthStatusOf, :type => :System
  end

  class ResourceStatus < Spira::Base
    configure :base_uri => SAMANTuxv.ResourceStatus
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#ResourceStatus")
    # Object Properties
    property :isResourceStatusOf, :predicate => SAMANTuxv.isResourceStatusOf, :type => :UxV
  end

  class UserRole < Spira::Base
    configure :base_uri => SAMANTuxv.UserRole
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UserRole")
    # Object Properties
    has_many :isUserRoleOf, :predicate => SAMANTuxv.isUserRoleOf, :type => :UserSettings
  end

  class UserSettings < Spira::Base
    configure :base_uri => SAMANTuxv.UserSettings
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UserSettings")
    # Object Properties
    property :hasUserRole, :predicate => SAMANTuxv.hasUserRole, :type => :UserRole
    property :isUserSettingsOf, :predicate => SAMANTuxv.isUserSettingsOf, :type => :Person
    # Data Properties
    property :hasPreferences, :predicate => SAMANTuxv.hasPreferences, :type => String
    property :isUpdated, :predicate => SAMANTuxv.isUpdated, :type => String
  end

  class UxVType < Spira::Base
    configure :base_uri => SAMANTuxv.UxVType
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UxVType")
    # Object Properties
    property :isUxVTypeOf, :predicate => SAMANTuxv.isUxVTypeOf, :type => :UxV
  end

  class Person < Spira::Base
    # User
    configure :base_uri => FOAF.Person
    type RDF::URI.new("http://xmlns.com/foaf/0.1/Person")
    # Object Properties
    property :hasID, :predicate => SAMANTuxv.hasID, :type => RDF::XSD.string
    has_many :hasUserSettings, :predicate => SAMANTuxv.hasUserSettings, :type => :UserSettings
    has_many :usesTestbed, :predicate => SAMANTuxv.usesTestbed, :type => :Testbed
    # Data Properties
    property :hasEmail, :predicate => SAMANTuxv.hasEmail, :type => String
    property :hasFirstName, :predicate => SAMANTuxv.hasFirstName, :type => String
    property :hasSurname, :predicate => SAMANTuxv.hasSurname, :type => String
    property :hasUserName, :predicate => SAMANTuxv.hasUserName, :type => String
    property :isSuperUser, :predicate => SAMANTuxv.isSuperUser, :type => Boolean
    property :lastLogin, :predicate => SAMANTuxv.lastLogin, :type => String
    property :hasPassword, :predicate => SAMANTuxv.hasPassword, :type => String
    property :hasUserID, :predicate => SAMANTuxv.hasUserID, :type => String
  end

  class ConfigParameters < Spira::Base
    configure :base_uri => SAMANTuxv.ConfigParameters
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#ConfigParameters")
    # Object Properties
    property :isConfigParametersOf, :predicate => SAMANTuxv.isConfigParametersOf, :type => :UxV
    property :hasExperimentResourceConfig, :predicate => SAMANTuxv.hasExperimentResourceConfig, :type => :ExperimentResourceConfig
    # Data Properties
    property :hasID, :predicate => SAMANTuxv.hasID, :type => RDF::XSD.string
    property :hasName, :predicate => SAMANTuxv.hasName, :type => String
    property :hasDescription, :predicate => SAMANTuxv.hasDescription, :type => String
    property :hasConfigParametersID, :predicate => SAMANTuxv.hasConfigParametersID, :type => String
    property :hasConfigParametersMinValue, :predicate => SAMANTuxv.hasConfigParametersMinValue, :type => Float
    property :hasConfigParametersMaxValue, :predicate => SAMANTuxv.hasConfigParametersMaxValue, :type => Float
  end

  class ExperimentResourceConfig < Spira::Base
    configure :base_uri => SAMANTuxv.ExperimentResourceConfig
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#ExperimentResourceConfig")
    # Object Properties
    property :isExperimentResourceConfigOf, :predicate => SAMANTuxv.isExperimentResourceConfigOf, :type => :ConfigParameters
    # Data Properties
    property :hasID, :predicate => SAMANTuxv.hasID, :type => RDF::XSD.string
    property :hasExperimentResourceConfigID, :predicate => SAMANTuxv.hasExperimentResourceConfigID, :type => String
    property :hasExperimentResourceConfigParamValue, :predicate => SAMANTuxv.hasExperimentResourceConfigParamValue, :type => Float
  end

  class HealthInformation < Spira::Base
    configure :base_uri => SAMANTuxv.HealthInformation
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#HealthInformation")
    # Object Properties
    property :isHealthInformationOf, :predicate => SAMANTuxv.isHealthInformationOf, :type => :UxV
    property :isHealthInformationOf, :predicate => SAMANTuxv.isHealthInformationOf, :type => :Testbed
    property :isHealthInformationOf, :predicate => SAMANTuxv.isHealthInformationOf, :type => :SensingDevice
    property :hasGeneralHealthStatus, :predicate => SAMANTuxv.hasGeneralHealthStatus, :type => :GeneralHealthStatus
    # Data Properties
    property :isUpdated, :predicate => SAMANTuxv.isUpdated, :type => String
    property :hasMessage, :predicate => SAMANTuxv.hasMessage, :type => String
  end

  class GeneralHealthStatus < Spira::Base
    configure :base_uri => SAMANTuxv.GeneralHealthStatus
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#GeneralHealthStatus")
    # Object Properties
    property :isGeneralHealthStatusOf, :predicate => SAMANTuxv.isGeneralHealthStatusOf, :type => :HealthInformation
  end

  class WiredInterface < Interface
    # Imported from omn-domain-wireless:WiredInterface
    configure :base_uri => OMNwireless.WiredInterface
    type RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#WiredInterface")
  end

  class WirelessInterface < Interface
    # Imported from omn-domain-wireless:WirelessInterface
    configure :base_uri => OMNwireless.WirelessInterface
    type RDF::URI.new("http://open-multinet.info/ontology/omn-domain-wireless#WirelessInterface")
    # Data Properties
    property :antennaCount, :predicate => OMNwireless.antennaCount, :type => RDF::XSD.integer
  end

  class UxV < Resource
    configure :base_uri => SAMANTuxv.UxV
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UxV")
    # Object Properties
    property :hasHealthStatus, :predicate => SAMANTuxv.hasHealthStatus, :type => :HealthStatus
    property :hasResourceStatus, :predicate => SAMANTuxv.hasResourceStatus, :type => :ResourceStatus
    property :hasHealthInformation, :predicate => SAMANTuxv.hasHealthInformation, :type => :HealthInformation
    property :isResourceOf, :predicate => SAMANTuxv.isResourceOf, :type => :Testbed
    property :hasUxVType, :predicate => SAMANTuxv.hasUxVType, :type => :UxVType
    property :hasLease, :predicate => OMNlifecycle.hasLease, :type => :Lease
    property :hasReservation, :predicate => OMNlifecycle.hasReservation, :type => :Reservation
    property :hasConfigParameters, :predicate => SAMANTuxv.hasConfigParameters, :type => :ConfigParameters
    property :hasSensorSystem, :predicate => SAMANTsensor.hasSensorSystem, :type => :System
    property :hasChild, :predicate => SAMANTuxv.hasChild, :type => :UxV
    property :hasParent, :predicate => SAMANTuxv.hasParent, :type => :UxV
    has_many :hasInterface, :predicate => OMNresource.hasInterface, :type => :Interface
    has_many :where, :predicate => GEO.where, :type => :Geometry

    # Data Properties
    property :resourceId, :predicate => OMNlifecycle.resourceId, :type => String
    property :hasDescription, :predicate => SAMANTuxv.hasDescription, :type => String
    property :hasName, :predicate => SAMANTuxv.hasName, :type => String
    property :hasStatusMessage, :predicate => SAMANTuxv.hasStatusMessage, :type => String
    property :hasComponentID, :predicate => OMNlifecycle.hasComponentID, :type => RDF::XSD.anyURI
    property :hasComponentManagerID, :predicate => OMNlifecycle.hasComponentManagerID, :type => URI
    property :hasComponentManagerName, :predicate => OMNlifecycle.hasComponentManagerName, :type => URI
    property :hasComponentName, :predicate => OMNlifecycle.hasComponentName, :type => RDF::XSD.string
    property :hasOriginalID, :predicate => OMNlifecycle.hasOriginalID, :type => String
    property :hasRole, :predicate => OMNlifecycle.hasRole, :type => String
    property :hasSliverID, :predicate => OMNlifecycle.hasSliverID, :type => String
    property :hasSliverName, :predicate => OMNlifecycle.hasSliverName, :type => String
    property :hasSliceID, :predicate => OMNlifecycle.hasSliceID, :type => String
    property :weight, :predicate => SAMANTuxv.weight, :type => RDF::XSD.double
    property :mtoWeight, :predicate => SAMANTuxv.mtoWeight, :type => RDF::XSD.double
    property :length, :predicate => SAMANTuxv.length, :type => RDF::XSD.double
    property :width, :predicate => SAMANTuxv.width, :type => RDF::XSD.double
    property :height, :predicate => SAMANTuxv.height, :type => RDF::XSD.double
    property :diameter, :predicate => SAMANTuxv.diameter, :type => RDF::XSD.double
    property :endurance, :predicate => SAMANTuxv.endurance, :type => RDF::XSD.integer
    property :battery, :predicate => SAMANTuxv.battery, :type => RDF::XSD.integer
  end

  class Lease < Reservation
    # Imported from omn-lifecycle:Lease
    configure :base_uri => OMNlifecycle.Lease
    type RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Lease")
    # Object Properties
    has_many :isReservationOf, :predicate => SAMANTuxv.isReservationOf, :type => :UxV
    property :hasReservationState, :predicate => OMNlifecycle.hasReservationState, :type => :ReservationState
    # Data Properties
    property :hasID, :predicate => OMNlifecycle.hasID, :type => String
    property :startTime, :predicate => OMNlifecycle.startTime, :type => RDF::XSD.dateTime
    property :expirationTime, :predicate => OMNlifecycle.expirationTime, :type => RDF::XSD.dateTime
    property :hasStatusMessage, :predicate => SAMANTuxv.hasStatusMessage, :type => String
    property :hasSliceID, :predicate => OMNlifecycle.hasSliceID, :type => String
  end

  class Unallocated < ReservationState # SFA -> Past / RAWFIE -> Released
    # Imported from omn-lifecycle:Unallocated
    configure :base_uri => OMNlifecycle.Unallocated
    type RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Unallocated")
  end

  class Allocated < ReservationState # SFA -> Accepted / RAWFIE -> Booked
    # Imported from omn-lifecycle:Allocated
    configure :base_uri => OMNlifecycle.Allocated
    type RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Allocated")
  end

  class Provisioned < ReservationState # SFA -> Active / RAWFIE -> Provisioned
    # Imported from omn-lifecycle:Provisioned
    configure :base_uri => OMNlifecycle.Provisioned
    type RDF::URI.new("http://open-multinet.info/ontology/omn-lifecycle#Provisioned")
  end

  class Pending < ReservationState # SFA -> Pending / RAWFIE -> Incomplete
    configure :base_uri => SAMANTuxv.Pending
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Pending")
  end

  class Cancelled < ReservationState
    configure :base_uri => SAMANTuxv.Cancelled
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Cancelled")
  end

  class AuV < UxVType
    configure :base_uri => SAMANTuxv.AuV
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#AuV")
  end

  class UaV < UxVType
    configure :base_uri => SAMANTuxv.UaV
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UaV")
  end

  class UgV < UxVType
    configure :base_uri => SAMANTuxv.UgV
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UgV")
  end

  class UsV < UxVType
    configure :base_uri => SAMANTuxv.UsV
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UsV")
  end

  class AuthorityUser < UserRole
    configure :base_uri => SAMANTuxv.AuthorityUser
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#AuthorityUser")
  end

  class Experimenter < UserRole
    configure :base_uri => SAMANTuxv.Experimenter
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Experimenter")
  end

  class TestbedManager < UserRole
    configure :base_uri => SAMANTuxv.TestbedManager
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#TestbedManager")
  end

  class Booked < ResourceStatus
    configure :base_uri => SAMANTuxv.Booked
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Booked")
  end

  class Released < ResourceStatus
    configure :base_uri => SAMANTuxv.Released
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Released")
  end

  class SleepMode < ResourceStatus
    configure :base_uri => SAMANTuxv.SleepMode
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#SleepMode")
  end

  class Critical < HealthStatus
    configure :base_uri => SAMANTuxv.Critical
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Critical")
  end

  class Ok < HealthStatus
    configure :base_uri => SAMANTuxv.OK
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#OK")
  end

  class Shutdown < HealthStatus
    configure :base_uri => SAMANTuxv.Shutdown
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Shutdown")
  end

  class Warning < HealthStatus
    configure :base_uri => SAMANTuxv.Warning
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Warning")
  end

  class Testbed < Infrastructure
    configure :base_uri => SAMANTuxv.Testbed
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Testbed")
    # Object Properties
    property :hasHealthStatus, :predicate => SAMANTuxv.hasHealthStatus, :type => :HealthStatus
    property :isTestbedOf, :predicate => SAMANTuxv.isTestbedOf, :type => :Person
    property :hasHealthInformation, :predicate => SAMANTuxv.hasHealthInformation, :type => :HealthInformation
    property :where, :predicate => GEO.where, :type => :Geometry
    has_many :hasResource, :predicate => SAMANTuxv.hasResource, :type => :UxV
    # Data Properties
    property :hasID, :predicate => SAMANTuxv.hasID, :type => RDF::XSD.string
    property :hasName, :predicate => SAMANTuxv.hasName, :type => String
    property :hasDescription, :predicate => SAMANTuxv.hasDescription, :type => String
    property :hasTestbedID, :predicate => SAMANTuxv.hasTestbedID, :type => String
    property :hasUavSupport, :predicate => SAMANTuxv.hasUavSupport, :type => Boolean
    property :hasUgvSupport, :predicate => SAMANTuxv.hasUgvSupport, :type => Boolean
    property :hasUsvSupport, :predicate => SAMANTuxv.hasUsvSupport, :type => Boolean
    property :hasStatusMessage, :predicate => SAMANTuxv.hasStatusMessage, :type => String
  end

  class Point < Geometry
    configure :base_uri => GML.Point
    type RDF::URI.new("http://www.opengis.net/gml/Point")
    # Data Properties
    property :pos, :predicate => GML.pos, :type => String
  end

  class Point3D < Geometry
    configure :base_uri => SAMANTuxv.Point3D
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#Point3D")
    # Data Properties
    property :lat, :predicate => GEO2003.lat, :type => RDF::XSD.double
    property :alt, :predicate => GEO2003.alt, :type => RDF::XSD.double
    property :long, :predicate => GEO2003.long, :type => RDF::XSD.double
  end

  class Polygon < Geometry
    configure :base_uri => GML.Polygon
    type RDF::URI.new("http://www.opengis.net/gml/Polygon")
    # Object Properties
    property :exterior, :predicate => GML.exterior, :type => :LinearRing
  end

  class LinearRing < Geometry
    configure :base_uri => GML.LinearRing
    type RDF::URI.new("http://www.opengis.net/gml/LinearRing")
    # Data Properties
    has_many :posList, :predicate => GML.posList, :type => String
  end

  class GeneralOK < GeneralHealthStatus
    configure :base_uri => SAMANTuxv.GeneralOK
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#GeneralOK")
  end

  class GeneralWarning < GeneralHealthStatus
    configure :base_uri => SAMANTuxv.GeneralWarning
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#GeneralWarning")
  end

  class GeneralCritical < GeneralHealthStatus
    configure :base_uri => SAMANTuxv.GeneralCritical
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#GeneralCritical")
  end

  class GeneralUnknown < GeneralHealthStatus
    configure :base_uri => SAMANTuxv.GeneralUnknown
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#GeneralUnknown")
  end

  ##### INDIVIDUALS ##### (modelled as ruby constants)

  ALLOCATED = Allocated.for("").save!
  CANCELLED = Cancelled.for("").save!
  PROVISIONED = Provisioned.for("").save!
  UNALLOCATED = Unallocated.for("").save!
  PENDING = Pending.for("").save!
  AUV = AuV.for("").save!
  AUTHORITYUSER = AuthorityUser.for("").save!
  BOOKED = Booked.for("").save!
  CRITICAL = Critical.for("").save!
  EXPERIMENTER = Experimenter.for("").save!
  OK = Ok.for("").save!
  RELEASED = Released.for("").save!
  SHUTDOWN = Shutdown.for("").save!
  SLEEPMODE = SleepMode.for("").save!
  TESTBEDMANAGER = TestbedManager.for("").save!
  UAV = UaV.for("").save!
  UGV = UgV.for("").save!
  USV = UsV.for("").save!
  WARNING = Warning.for("").save!
  GENERALWARNING = GeneralWarning.for("").save!
  GENERALCRITICAL = GeneralCritical.for("").save!
  GENERALOK = GeneralOK.for("").save!
  GENERALUNKNOWN = GeneralUnknown.for("").save!

end