module SAMANT

  RDF::Util::Logger.logger.parent.level = 'off'
  # Ontology Namespaces (prefixes)
  # Built in vocabs: OWL, RDF, RDFS

  SAMANTsensor = RDF::Vocabulary.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#")
  SAMANTuxv = RDF::Vocabulary.new("http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#")
  QU = RDF::Vocabulary.new("http://purl.oclc.org/NET/ssnx/qu/qu#")
  DIM  = RDF::Vocabulary.new("http://purl.oclc.org/NET/ssnx/qu/dim#")
  SSN = RDF::Vocabulary.new("http://purl.oclc.org/NET/ssnx/ssn#")
  DUL = RDF::Vocabulary.new("http://www.loa-cnr.it/ontologies/DUL.owl#")
  UNIT = RDF::Vocabulary.new("http://purl.oclc.org/NET/ssnx/qu/unit#")


  ##### CLASSES #####

  class Quality < Spira::Base
    configure :base_uri => DUL.Quality
    type RDF::URI.new("http://www.loa-cnr.it/ontologies/DUL.owl#Quality")
  end

  class QuantityKind < Quality
    configure :base_uri => QU.QuantityKind
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/qu#QuantityKind")
    # Object Properties
    has_many :isPropertyOf, :predicate => SSN.isPropertyOf, :type => :FeatureOfInterest
  end

  class UnitOfMeasure < Spira::Base
    configure :base_uri => DUL.UnitOfMeasure
    type RDF::URI.new("http://www.loa-cnr.it/ontologies/DUL.owl#UnitOfMeasure")
  end

  class Unit < UnitOfMeasure
    configure :base_uri => QU.Unit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/qu#Unit")
    # Object Properties
    property :isUnitOf, :predicate => SAMANTsensor.isUnitOf, :type => :SensingDevice
  end

  class SensingDevice < Spira::Base
    configure :base_uri => SSN.SensingDevice
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/ssn#SensingDevice")
    # Object Properties
    property :isPartOf, :predicate => DUL.isPartOf, :type => :System
    has_many :observes, :predicate => SSN.observes, :type => :QuantityKind
    has_many :hasUnit, :predicate => SAMANTsensor.hasUnit, :type => :Unit
    # Data Properties
    property :hasVendorName, :predicate => SAMANTsensor.hasVendorName, :type => RDF::XSD.string
    property :hasProductName, :predicate => SAMANTsensor.hasProductName, :type => RDF::XSD.string
    property :hasSerial, :predicate => SAMANTsensor.hasSerial, :type => RDF::XSD.string
    property :hasID, :predicate => SAMANTsensor.hasID, :type => RDF::XSD.string
    property :hasDescription, :predicate => SAMANTsensor.hasDescription, :type => RDF::XSD.string
    property :consumesPower, :predicate => SAMANTuxv.consumesPower, :type => RDF::XSD.string
  end

  class System < Spira::Base
    configure :base_uri => SSN.System
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/ssn#System")
    # Object Properties
    has_many :hasSubSystem, :predicate => SSN.hasSubSystem, :type => :SensingDevice
    has_many :hasSubSystem, :predicate => SSN.hasSubSystem, :type => :System
    property :isSensorSystemOf, :predicate => SAMANTsensor.isSensorSystemOf, :type => :Uxv
    property :hasHealthStatus, :predicate => SAMANTuxv.hasHealthStatus, :type => :HealthStatus
    # Data Properties
    property :hasVendorName, :predicate => SAMANTsensor.hasVendorName, :type => RDF::XSD.string
    property :hasProductName, :predicate => SAMANTsensor.hasProductName, :type => RDF::XSD.string
    property :hasSerial, :predicate => SAMANTsensor.hasSerial, :type => RDF::XSD.string
    property :hasID, :predicate => SAMANTsensor.hasID, :type => RDF::XSD.string
    property :hasDescription, :predicate => SAMANTsensor.hasDescription, :type => RDF::XSD.string
  end

  class FeatureOfInterest < Spira::Base
    configure :base_uri => SSN.FeatureOfInterest
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/ssn#FeatureOfInterest")
    # Object Properties
    has_many :hasProperty, :predicate => SSN.hassProperty, :type => :QuantityKind
  end

  class Water < FeatureOfInterest
    configure :base_uri => SAMANTsensor.Water
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Water")
  end

  class Air < FeatureOfInterest
    configure :base_uri => SAMANTsensor.Air
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Air")
  end

  class Ground < FeatureOfInterest
    configure :base_uri => SAMANTsensor.Ground
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Ground")
  end

  class AccelerationSensor < SensingDevice
    configure :base_uri => SAMANTsensor.AccelerationSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#AccelerationSensor")
  end

  class AngleSensor < SensingDevice
    configure :base_uri => SAMANTsensor.AngleSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#AngleSensor")
  end

  class CapacitanceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.CapacitanceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#CapacitanceSensor")
  end

  class ConductanceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ConductanceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ConductanceSensor")
  end

  class ConcentrationSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ConcentrationSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ConcentrationSensor")
  end

  class DistanceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.DistanceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#DistanceSensor")
  end

  class DurationSensor < SensingDevice
    configure :base_uri => SAMANTsensor.DurationSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#DurationSensor")
  end

  class ElectricConductivitySensor < SensingDevice
    configure :base_uri => SAMANTsensor.ElectricConductivitySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ElectricConductivitySensor")
  end

  class ElectricCurrentRateSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ElectricCurrentRateSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ElectricCurrentRateSensor")
  end

  class ElectricPotentialSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ElectricPotentialSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ElectricPotentialSensor")
  end

  class ElectricResistanceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ElectricResistanceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ElectricResistanceSensor")
  end

  class EnergySensor < SensingDevice
    configure :base_uri => SAMANTsensor.EnergySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#EnergySensor")
  end

  class GeolocationSensor < SensingDevice
    configure :base_uri => SAMANTsensor.GeolocationSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#GeolocationSensor")
  end

  class ForceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ForceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ForceSensor")
  end

  class FrequencySensor < SensingDevice
    configure :base_uri => SAMANTsensor.FrequencySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#FrequencySensor")
  end

  class ImageSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ImageSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ImageSensor")
  end

  class ImageSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ImageSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ImageSensor")
  end

  class ImageSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ImageSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ImageSensor")
  end

  class MassSensor < SensingDevice
    configure :base_uri => SAMANTsensor.MassSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#MassSensor")
  end

  class PowerSensor < SensingDevice
    configure :base_uri => SAMANTsensor.PowerSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#PowerSensor")
  end

  class RotationalSpeedSensor < SensingDevice
    configure :base_uri => SAMANTsensor.RotationalSpeedSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#RotationalSpeedSensor")
  end

  class InformationDataSensor < SensingDevice
    configure :base_uri => SAMANTsensor.InformationDataSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataSensor")
  end

  class TurbiditySensor < SensingDevice
    configure :base_uri => SAMANTsensor.TurbiditySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#TurbiditySensor")
  end

  class SalinitySensor < SensingDevice
    configure :base_uri => SAMANTsensor.SalinitySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SalinitySensor")
  end

  class StressOrPressureSensor < SensingDevice
    configure :base_uri => SAMANTsensor.StressOrPressureSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#StressOrPressureSensor")
  end

  class TemperatureSensor < SensingDevice
    configure :base_uri => SAMANTsensor.TemperatureSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#TemperatureSensor")
  end

  class VelocityorSpeedSensor < SensingDevice
    configure :base_uri => SAMANTsensor.VelocityorSpeedSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#VelocityorSpeedSensor")
  end

  class VolumeSensor < SensingDevice
    configure :base_uri => SAMANTsensor.VolumeSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#VolumeSensor")
  end

  class ConductivitySensor < SensingDevice
    configure :base_uri => SAMANTsensor.ConductivitySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ConductivitySensor")
  end

  class SoundSensor < SensingDevice
    configure :base_uri => SAMANTsensor.SoundSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SoundSensor")
  end

  class SoundSpeedSensor < VelocityorSpeedSensor
    configure :base_uri => SAMANTsensor.SoundSpeedSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SoundSpeedSensor")
  end

  class SimpleQuantityKind < QuantityKind
  configure :base_uri => QU.SimpleQuantityKind
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/qu#SimpleQuantityKind")
  end

  class Conductance < QuantityKind
    configure :base_uri => DIM.Conductance
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Conductance")
  end

  class ConductanceUnit < Unit
    configure :base_uri => DIM.ConductanceUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConductanceUnit")
  end

  class Salinity < SimpleQuantityKind
    configure :base_uri => SAMANTsensor.Salinity
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Salinity")
  end

  class Air < FeatureOfInterest
    configure :base_uri => SAMANTsensor.Air
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Air")
  end

  class Ground < FeatureOfInterest
    configure :base_uri => SAMANTsensor.Ground
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Ground")
  end

  #########################
  # Magnitudes and Units
  #########################

  class Acceleration < QuantityKind
    configure :base_uri => DIM.Acceleration
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Acceleration")
  end

  class AccelerationUnit < Unit
    configure :base_uri => DIM.AccelerationUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AccelerationUnit")
  end

  class Angle < QuantityKind
    configure :base_uri => DIM.Angle
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Angle")
  end

  class AngleUnit < Unit
    configure :base_uri => DIM.AngleUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class Capacitance < QuantityKind
    configure :base_uri => DIM.Capacitance
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Capacitance")
  end

  class CapacitanceUnit < Unit
    configure :base_uri => DIM.CapacitanceUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#CapacitanceUnit")
  end

  class Concentration < QuantityKind
    configure :base_uri => DIM.Concentration
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Concentration")
  end

  class ConcentrationUnit < Unit
    configure :base_uri => DIM.ConcentrationUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConcentrationUnit")
  end

  class Dimensionless < QuantityKind
    configure :base_uri => DIM.Dimensionless
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Dimensionless")
  end

  class DimensionlessUnit < Unit
    configure :base_uri => DIM.DimensionlessUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DimensionlessUnit")
  end

  class Distance < QuantityKind
    configure :base_uri => DIM.Distance
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Distance")
  end

  class DistanceUnit < Unit
    configure :base_uri => DIM.DistanceUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DistanceUnit")
  end

  class Duration < QuantityKind
    configure :base_uri => DIM.Duration
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Duration")
  end

  class DurationUnit < Unit
    configure :base_uri => DIM.DurationUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DurationUnit")
  end

  class ElectricConductivity < QuantityKind
    configure :base_uri => DIM.ElectricConductivity
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricConductivity")
  end

  class ElectricConductivityUnit < Unit
    configure :base_uri => DIM.ElectricConductivityUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricConductivityUnit")
  end

  class ElectricCurrentRate < QuantityKind
    configure :base_uri => DIM.ElectricCurrentRate
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricCurrentRate")
  end

  class ElectricCurrentRateUnit < Unit
    configure :base_uri => DIM.ElectricCurrentRateUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricCurrentRateUnit")
  end

  class ElectricPotential < QuantityKind
    configure :base_uri => DIM.ElectricPotential
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricPotential")
  end

  class ElectricPotentialUnit < Unit
    configure :base_uri => DIM.ElectricPotentialUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricPotentialUnit")
  end

  class ElectricResistance < QuantityKind
    configure :base_uri => DIM.ElectricResistance
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricResistance")
  end

  class ElectricResistanceUnit < Unit
    configure :base_uri => DIM.ElectricResistanceUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricResistanceUnit")
  end

  class Energy < QuantityKind
    configure :base_uri => DIM.Energy
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Energy")
  end

  class EnergyUnit < Unit
    configure :base_uri => DIM.EnergyUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#EnergyUnit")
  end

  class Force < QuantityKind
    configure :base_uri => DIM.Force
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Force")
  end

  class ForceUnit < Unit
    configure :base_uri => DIM.ForceUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ForceUnit")
  end

  class Frequency < QuantityKind
    configure :base_uri => DIM.Frequency
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Frequency")
  end

  class FrequencyUnit < Unit
    configure :base_uri => DIM.FrequencyUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#FrequencyUnit")
  end

  class Geolocation < QuantityKind
    configure :base_uri => DIM.Geolocation
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Geolocation")
  end

  class GeolocationUnit < Unit
    configure :base_uri => DIM.GeolocationUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#GeolocationUnit")
  end

  class MagneticFluxDensity < QuantityKind
    configure :base_uri => DIM.MagneticFluxDensity
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MagneticFluxDensity")
  end

  class MagneticFluxDensityUnit < Unit
    configure :base_uri => DIM.MagneticFluxDensityUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MagneticFluxDensityUnit")
  end

  class InformationData < SimpleQuantityKind
    configure :base_uri => SAMANTsensor.InformationData
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationData")
  end

  class InformationDataUnit < Unit
    configure :base_uri => SAMANTsensor.InformationDataUnit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
  end

  class Power < SimpleQuantityKind
    configure :base_uri => SAMANTsensor.Power
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Power")
  end

  class PowerUnit < Unit
    configure :base_uri => SAMANTsensor.PowerUnit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#PowerUnit")
  end

  class LevelOfAFieldQuantity < QuantityKind
    configure :base_uri => DIM.LevelOfAFieldQuantity
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#LevelOfAFieldQuantity")
  end

  class LevelOfAFieldQuantityUnit < Unit
    configure :base_uri => DIM.LevelOfAFieldQuantityUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#LevelOfAFieldQuantityUnit")
  end

  class Mass < QuantityKind
    configure :base_uri => DIM.Mass
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Mass")
  end

  class MassUnit < Unit
    configure :base_uri => DIM.MassUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MassUnit")
  end

  class Image < QuantityKind
    configure :base_uri => DIM.Image
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Image")
  end

  class ImageUnit < Unit
    configure :base_uri => DIM.ImageUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ImageUnit")
  end

  class RotationalSpeed < QuantityKind
    configure :base_uri => DIM.RotationalSpeed
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeed")
  end

  class RotationalSpeedUnit < Unit
    configure :base_uri => DIM.RotationalSpeedUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class StressOrPressure < QuantityKind
    configure :base_uri => DIM.StressOrPressure
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressure")
  end

  class StressOrPressureUnit < Unit
    configure :base_uri => DIM.StressOrPressureUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressureUnit")
  end

  class Turbidity < SimpleQuantityKind
    configure :base_uri => SAMANTsensor.Turbidity
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#Turbidity")
  end

  class TurbidityUnit < Unit
    configure :base_uri => SAMANTsensor.TurbidityUnit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#TurbidityUnit")
  end


  class SalinityUnit < Unit
    configure :base_uri => SAMANTsensor.SalinityUnit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SalinityUnit")
  end

  class Temperature < QuantityKind
    configure :base_uri => DIM.Temperature
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Temperature")
  end

  class TemperatureUnit < Unit
    configure :base_uri => DIM.TemperatureUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#TemperatureUnit")
  end

  class VelocityOrSpeed < QuantityKind
    configure :base_uri => DIM.VelocityOrSpeed
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#VelocityOrSpeed")
  end

  class VelocityOrSpeedUnit < Unit
    configure :base_uri => DIM.VelocityOrSpeedUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#VelocityOrSpeedUnit")
  end

  class Volume < QuantityKind
    configure :base_uri => DIM.Volume
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#Volume")
  end

  class VolumeUnit < Unit
    configure :base_uri => DIM.VolumeUnit
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#VolumeUnit")
  end


  ###############
  # Individuals
  ###############

  class MetrePerSecondSquared < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#metrePerSecondSquared"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AccelerationUnit")
  end

  class Radian < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#radian"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class DegreeUnitOfAngle < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#degreeUnitOfAngle"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class SecondUnitOfAngle < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#secondUnitOfAngle"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class MinuteUnitOfAngle < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#minuteUnitOfAngle"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class Percent < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#percent"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DimensionlessUnit")
  end

  class PartsPerMillion < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#partsPerMillion"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConcentrationUnit")
  end

  class PartsPerBillion < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#partsPerBillion"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConcentrationUnit")
  end

  class Ph < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#pH"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConcentrationUnit")
  end

  class MolePerLitre < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#molePerLitre"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConcentrationUnit")
  end

  class Metre < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#metre"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DistanceUnit")
  end

  class SecondUnitOfTime < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#secondUnitOfTime"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DurationUnit")
  end

  class SiemensPerMetre < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#siemensPerMetre"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricConductivityUnit")
  end

  class Siemens < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#siemens"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ConductanceUnit")
  end

  class Ampere < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#ampere"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricCurrentRateUnit")
  end

  # TODO check if case sensitive e.g. Volt or volt
  class Volt < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#volt"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricPotentialUnit")
  end

  class Newton < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#newton"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ForceUnit")
  end

  class Hertz < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#hertz"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#FrequencyUnit")
  end

  class Bit < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#bit"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
  end

  class Byte < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#byte"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
  end

  class Pixel < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#pixel"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ImageUnit")
  end

  class Decibel < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#decibel"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#LevelOfAFieldQuantityUnit")
  end

  class Kilogram < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#kilogram"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MassUnit")
  end

  class DegreePerSecond < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#degreePerSecond"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class RadianPerSecond < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#radianPerSecond"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class RotationPerMinute < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#rotationPerMinute"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class Psu < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#psu"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SalinityUnit")
  end

  class Pascal < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#pascal"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressureUnit")
  end

  class Millibar < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#millibar"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressureUnit")
  end

  class Kelvin < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#kelvin"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#TemperatureUnit")
  end

  class DegreeCelsius < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#degreeCelsius"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#TemperatureUnit")
  end

  class Gauss < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#gauss"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MagneticFluxDensityUnit")
  end

  class Tesla < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#tesla"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MagneticFluxDensityUnit")
  end

  class Ntu < Spira::Base
    configure :base_uri => "http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ntu"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#TurbidityUnit")
  end

  class MetrePerSecond < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/unit#metrePerSecond"
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#VelocityOrSpeedUnit")
  end

  class AtmosphericPressure < Spira::Base
    configure :base_uri => "http://purl.oclc.org/NET/ssnx/qu/quantity#atmosphericPressure"
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressure")
  end

  METERPERSECONDSQUARED = MetrePerSecondSquared.for("").save!
  RADIAN = Radian.for("").save!
  DEGREEUNITOFANGLE = DegreeUnitOfAngle.for("").save!
  SECONDUNITOFANGLE = SecondUnitOfAngle.for("").save!
  MINUTEUNITOFANGLE = MinuteUnitOfAngle.for("").save!
  PERCENT = Percent.for("").save!
  PARTSPERMILLION = PartsPerMillion.for("").save!
  PARTSPERBILLION = PartsPerBillion.for("").save!
  PH = Ph.for("").save!
  MOLEPERLITRE = MolePerLitre.for("").save!
  METRE = Metre.for("").save!
  SECONDUNITOFTIME = SecondUnitOfTime.for("").save!
  SIEMENSPERMETRE = SiemensPerMetre.for("").save!
  SIEMENS = Siemens.for("").save!
  AMPERE = Ampere.for("").save!
  VOLT = Volt.for("").save!
  NEWTON = Newton.for("").save!
  HERTZ = Hertz.for("").save!
  BIT = Bit.for("").save!
  BYTE = Byte.for("").save!
  PIXEL = Pixel.for("").save!
  KILOGRAM = Kilogram.for("").save!
  DECIBEL = Decibel.for("").save!
  RADIANPERSECOND = RadianPerSecond.for("").save!
  DEGREEPERSECOND = DegreePerSecond.for("").save!
  ROTATIONPERMINUTE = RotationPerMinute.for("").save!
  PSU = Psu.for("").save!
  PASCAL = Pascal.for("").save!
  MILLIBAR = Millibar.for("").save!
  KELVIN = Kelvin.for("").save!
  DEGREECELSIUS = DegreeCelsius.for("").save!
  NTU = Ntu.for("").save!
  METREPERSECOND = MetrePerSecond.for("").save!
  GROUND = Ground.for("")
  AIR = Air.for("")
  WATER = Water.for("")
  GEOLOCATION = Geolocation.for("").save!
  ATMOSPHERICPRESSURE = AtmosphericPressure.for("").save!
  ROTATIONALSPEED = RotationalSpeed.for("").save!
  ACCELERATION = Acceleration.for("").save!
  MAGNETICFLUXDENSITY = MagneticFluxDensity.for("").save!
  IMAGE = Image.for("").save!
  TEMPERATURE = Temperature.for("").save!
  CONCENTRATION = Concentration.for("").save!
  CONDUCTANCE = Conductance.for("").save!

end