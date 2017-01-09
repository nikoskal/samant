module SAMANT

  RDF::Util::Logger.logger.parent.level = 'off'
  # Ontology Namespaces (prefixes)
  # Built in vocabs: OWL, RDF, RDFS

  SAMANTsensor = RDF::Vocabulary.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#")
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
    property :isPropertyOf, :predicate => SSN.isPropertyOf, :type => :FeatureOfInterest
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
    property :hasVendorName, :predicate => SAMANTsensor.hasVendorName, :type => String
    property :hasProductName, :predicate => SAMANTsensor.hasProductName, :type => String
    property :hasSerial, :predicate => SAMANTsensor.hasSerial, :type => String
    property :hasID, :predicate => SAMANTsensor.hasID, :type => String
    property :hasDescription, :predicate => SAMANTsensor.hasDescription, :type => String
  end

  class System < Spira::Base
    configure :base_uri => SSN.System
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/ssn#System")
    # Object Properties
    has_many :hasSubSystem, :predicate => SSN.hasSubSystem, :type => :SensingDevice
    has_many :hasSubSystem, :predicate => SSN.hasSubSystem, :type => :System
    property :isSensorSystemOf, :predicate => SAMANTsensor.isSensorSystemOf, :type => :UxV
    property :isSensorSystemOf, :predicate => SAMANTsensor.isSensorSystemOf, :type => :HealthStatus
    # Data Properties
    property :hasVendorName, :predicate => SAMANTsensor.hasVendorName, :type => String
    property :hasVendorName, :predicate => SAMANTsensor.hasVendorName, :type => String
    property :hasProductName, :predicate => SAMANTsensor.hasProductName, :type => String
    property :hasSerial, :predicate => SAMANTsensor.hasSerial, :type => String
    property :hasID, :predicate => SAMANTsensor.hasID, :type => String
    property :hasDescription, :predicate => SAMANTsensor.hasDescription, :type => String
  end


  class FeatureOfInterest < Spira::Base
    configure :base_uri => SSN.FeatureOfInterest
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/ssn#FeatureOfInterest")
    # Object Properties
    property :hasProperty, :predicate => SSN.hassProperty, :type => :QuantityKind
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

  class ForceSensor < SensingDevice
    configure :base_uri => SAMANTsensor.ForceSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#ForceSensor")
  end

  class FrequencySensor < SensingDevice
    configure :base_uri => SAMANTsensor.FrequencySensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#FrequencySensor")
  end

  class MassSensor < SensingDevice
    configure :base_uri => SAMANTsensor.MassSensor
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#MassSensor")
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

  class InformationData < SimpleQuantityKind
    configure :base_uri => SAMANTsensor.InformationData
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationData")
  end

  class InformationDataUnit < Unit
    configure :base_uri => SAMANTsensor.InformationDataUnit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
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


  ###############
  # Individuals
  ###############

  class MetrePerSecondSquared < Spira::Base
    configure :base_uri => UNIT.MetrePerSecondSquared
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AccelerationUnit")
  end

  class Radian < Spira::Base
    configure :base_uri => UNIT.Radian
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#AngleUnit")
  end

  class Percent < Spira::Base
    configure :base_uri => UNIT.Percent
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DimensionlessUnit")
  end

  class PartsPerMillion < Spira::Base
    configure :base_uri => UNIT.PartsPerMillion
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DimensionlessUnit")
  end

  class PartsPerBillion < Spira::Base
    configure :base_uri => UNIT.PartsPerBillion
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DimensionlessUnit")
  end

  class Metre < Spira::Base
    configure :base_uri => UNIT.Metre
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DistanceUnit")
  end

  class SecondUnitOfTime < Spira::Base
    configure :base_uri => UNIT.SecondUnitOfTime
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#DurationUnit")
  end

  class SiemensPerMetre < Spira::Base
    configure :base_uri => UNIT.SiemensPerMetre
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricConductivityUnit")
  end

  class Ampere < Spira::Base
    configure :base_uri => UNIT.Ampere
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricCurrentRateUnit")
  end

  # TODO check if case sensitive e.g. Volt or volt
  class Volt < Spira::Base
    configure :base_uri => UNIT.Volt
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ElectricPotentialUnit")
  end

  class Newton < Spira::Base
    configure :base_uri => UNIT.Newton
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#ForceUnit")
  end

  class Hertz < Spira::Base
    configure :base_uri => UNIT.Hertz
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#FrequencyUnit")
  end

  class Bit < Spira::Base
    configure :base_uri => SAMANTsensor.Bit
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
  end

  class Byte < Spira::Base
    configure :base_uri => SAMANTsensor.Byte
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#InformationDataUnit")
  end

  class Decibel < Spira::Base
    configure :base_uri => UNIT.Decibel
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#LevelOfAFieldQuantityUnit")
  end

  class Kilogram < Spira::Base
    configure :base_uri => UNIT.Kilogram
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#MassUnit")
  end

  class RadianPerSecond < Spira::Base
    configure :base_uri => UNIT.RadianPerSecond
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class RotationPerMinute < Spira::Base
    configure :base_uri => UNIT.RotationPerMinute
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#RotationalSpeedUnit")
  end

  class Psu < Spira::Base
    configure :base_uri => SAMANTsensor.Psu
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#SalinityUnit")
  end

  class Pascal < Spira::Base
    configure :base_uri => UNIT.Pascal
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#StressOrPressureUnit")
  end

  class Kelvin < Spira::Base
    configure :base_uri => UNIT.Kelvin
    type RDF::URI.new("http://purl.oclc.org/NET/ssnx/qu/dim#TemperatureUnit")
  end

  class Ntu < Spira::Base
    configure :base_uri => SAMANTsensor.Ntu
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#TurbidityUnit")
  end

  class MetrePerSecond < Unit
    configure :base_uri => UNIT.MetrePerSecond
    type RDF::URI.new("http://www.semanticweb.org/rawfie/samant/omn-domain-sensor#VelocityOrSpeedUnit")
  end

  METERPERSECONDSQUARED = MetrePerSecondSquared.for("").save!
  RADIAN = Radian.for("").save!
  PERCENT = Percent.for("").save!
  PARTSPERMILLION = PartsPerMillion.for("").save!
  PARTSPERBILLION = PartsPerBillion.for("").save!
  METRE = Metre.for("").save!
  SECONDUNITOFTIME = SecondUnitOfTime.for("").save!
  SIEMENSPERMETRE = SiemensPerMetre.for("").save!
  AMPERE = Ampere.for("").save!
  VOLT = Volt.for("").save!
  NEWTON = Newton.for("").save!
  HERTZ = Hertz.for("").save!
  BIT = Bit.for("").save!
  BYTE = Byte.for("").save!
  KILOGRAM = Kilogram.for("").save!
  DECIBEL = Decibel.for("").save!
  RADIANPERSECOND = RadianPerSecond.for("").save!
  ROTATIONPERMINUTE = RotationPerMinute.for("").save!
  PSU = Psu.for("").save!
  PASCAL = Pascal.for("").save!
  KELVIN = Kelvin.for("").save!
  NTU = Ntu.for("").save!
  METREPERSECOND = MetrePerSecond.for("").save!


  GROUND = Ground.for("").save!
  AIR = Air.for("").save!
  WATER = Water.for("").save!
end