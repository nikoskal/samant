require 'data_objects'
require 'rdf/do'
require 'do_sqlite3'
$repository = Spira.repository = RDF::DataObjects::Repository.new uri: "sqlite3:./test.db"
require_relative '../samant_models/sensor.rb'
require_relative '../samant_models/uxv.rb'

# Repopulate triplestore
RDF::Util::Logger.logger.parent.level = 'off'

auv1MultiSensor = SAMANT::System.for("urn:auv+multi+sensor".to_sym)
auv1MultiSensor.save

point11 = SAMANT::Point.for("urn:point11".to_sym)
point11.pos = "45.256 -71.92"
point11.save

point21 = SAMANT::Point.for("urn:point21".to_sym)
point21.pos = "55.356 31.92"
point21.save

point31 = SAMANT::Point.for("urn:point31".to_sym)
point31.pos = "-65.356 41.92"
point31.save

uav1Point3D = SAMANT::Point3D.for("urn:uav+point3D".to_sym)
uav1Point3D.lat = 55.701
uav1Point3D.long = 12.552
uav1Point3D.alt = 34.556
uav1Point3D.save

ugv1Point3D = SAMANT::Point3D.for("urn:ugv+point3D".to_sym)
ugv1Point3D.lat = 30.701
ugv1Point3D.long = 23.552
ugv1Point3D.alt = 65.556
ugv1Point3D.save

auv1Point3D = SAMANT::Point3D.for("urn:auv+point3D".to_sym)
auv1Point3D.lat = 21.701
auv1Point3D.long = 93.552
auv1Point3D.alt = 85.556
auv1Point3D.save

uavLinearRing = SAMANT::LinearRing.for("urn:uav+linear+ring".to_sym)
uavLinearRing.posList << "45.256 -110.45"
uavLinearRing.posList << "46.46 -109.48"
uavLinearRing.posList << "43.84 -109.86"
uavLinearRing.posList << "45.256 -110.45"
uavLinearRing.save

ugvLinearRing = SAMANT::LinearRing.for("urn:ugv+linear+ring".to_sym)
ugvLinearRing.posList << "43.256 110.45"
ugvLinearRing.posList << "43.46 109.48"
ugvLinearRing.posList << "44.84 109.86"
ugvLinearRing.posList << "43.256 110.45"
ugvLinearRing.save

auvLinearRing = SAMANT::LinearRing.for("urn:ugv+linear+ring".to_sym)
auvLinearRing.posList << "-42.256 110.45"
auvLinearRing.posList << "-42.46 109.48"
auvLinearRing.posList << "-42.84 109.86"
auvLinearRing.posList << "-42.256 110.45"
auvLinearRing.save

uavPolygon = SAMANT::Polygon.for("urn:uav+polygon".to_sym)
uavPolygon.exterior = uavLinearRing
uavPolygon.save

ugvPolygon = SAMANT::Polygon.for("urn:ugv+polygon".to_sym)
ugvPolygon.exterior = ugvLinearRing
ugvPolygon.save

auvPolygon = SAMANT::Polygon.for("urn:auv+polygon".to_sym)
auvPolygon.exterior = auvLinearRing
auvPolygon.save

dimitrisSettings = SAMANT::UserSettings.for("urn:dimitris+user+settings".to_sym)
dimitrisSettings.hasUserRole = SAMANT::AUTHORITYUSER
dimitrisSettings.hasPreferences = "preferences1"
dimitrisSettings.isUpdated = "2015-11-11 03:00:00"
dimitrisSettings.save

nikosSettings = SAMANT::UserSettings.for("urn:nikos+user+settings".to_sym)
nikosSettings.hasUserRole = SAMANT::EXPERIMENTER
nikosSettings.hasPreferences = "preferences2"
nikosSettings.isUpdated = "2013-11-11 03:00:00"
nikosSettings.save

mariosSettings = SAMANT::UserSettings.for("urn:marios+user+settings".to_sym)
mariosSettings.hasUserRole = SAMANT::TESTBEDMANAGER
mariosSettings.hasPreferences = "preferences3"
mariosSettings.isUpdated = "2012-11-11 03:00:00"
mariosSettings.save

uavHealthInformation = SAMANT::HealthInformation.for("urn:uav+health+information+test".to_sym)
uavHealthInformation.hasGeneralHealthStatus = SAMANT::GENERALOK
uavHealthInformation.isUpdated = "2016-11-11 04:00:00"
uavHealthInformation.save

ugvHealthInformation = SAMANT::HealthInformation.for("urn:ugv+health+information+test".to_sym)
ugvHealthInformation.hasGeneralHealthStatus = SAMANT::GENERALCRITICAL
ugvHealthInformation.isUpdated = "2017-10-10 04:00:00"
ugvHealthInformation.save

auvHealthInformation = SAMANT::HealthInformation.for("urn:auv+health+information+test".to_sym)
auvHealthInformation.hasGeneralHealthStatus = SAMANT::GENERALWARNING
auvHealthInformation.isUpdated = "2015-9-9 04:00:00"
auvHealthInformation.save

uavTestbed = SAMANT::Testbed.for("urn:UaV+testbed".to_sym)
uavTestbed.hasHealthStatus = SAMANT::OK
uavTestbed.hasHealthInformation = uavHealthInformation
uavTestbed.where = point11
uavTestbed.where = uavPolygon
uavTestbed.hasName = "UaVTestbed"
uavTestbed.hasStatusMessage = "functional"
uavTestbed.hasDescription = "descr1"
uavTestbed.hasTestbedID = "UaV24455"
uavTestbed.hasUavSupport = true
uavTestbed.hasUgvSupport = false
uavTestbed.hasUsvSupport = false
uavTestbed.save

ugvTestbed = SAMANT::Testbed.for("urn:UgV+testbed".to_sym)
ugvTestbed.hasHealthStatus = SAMANT::WARNING
ugvTestbed.hasHealthInformation = ugvHealthInformation
ugvTestbed.where = point21
ugvTestbed.where = uavPolygon
ugvTestbed.hasName = "UgVTestbed"
ugvTestbed.hasStatusMessage = "alert"
ugvTestbed.hasDescription = "descr2"
ugvTestbed.hasTestbedID = "UgV28980"
ugvTestbed.hasUavSupport = false
ugvTestbed.hasUgvSupport = true
ugvTestbed.hasUsvSupport = false
ugvTestbed.save

auvTestbed = SAMANT::Testbed.for("urn:AuV+testbed".to_sym)
auvTestbed.hasHealthStatus = SAMANT::WARNING
auvTestbed.hasHealthInformation = auvHealthInformation
auvTestbed.where = point31
auvTestbed.where = auvPolygon
auvTestbed.hasName = "AuVTestbed"
auvTestbed.hasStatusMessage = "hehe"
auvTestbed.hasDescription = "descr3"
auvTestbed.hasTestbedID = "AuV39050"
auvTestbed.hasUavSupport = false
auvTestbed.hasUgvSupport = false
auvTestbed.hasUsvSupport = true
auvTestbed.save

uav1ExpResConf = SAMANT::ExperimentResourceConfig.for("urn:uav1+exp+resource+config".to_sym)
uav1ExpResConf.hasExperimentResourceConfigID = "UaV1ExpResConfID"
uav1ExpResConf.hasExperimentResourceConfigParamValue = 4.5
uav1ExpResConf.save

ugv1ExpResConf = SAMANT::ExperimentResourceConfig.for("urn:ugv1+exp+resource+config".to_sym)
ugv1ExpResConf.hasExperimentResourceConfigID = "UgV1ExpResConfID"
ugv1ExpResConf.hasExperimentResourceConfigParamValue = 10.5
ugv1ExpResConf.save

auv1ExpResConf = SAMANT::ExperimentResourceConfig.for("urn:auv1+exp+resource+config".to_sym)
auv1ExpResConf.hasExperimentResourceConfigID = "AuV1ExpResConfID"
auv1ExpResConf.hasExperimentResourceConfigParamValue = 13.5
auv1ExpResConf.save

uav1ConfigParameters = SAMANT::ConfigParameters.for("urn:uav1+config+parameters+test".to_sym)
uav1ConfigParameters.hasExperimentResourceConfig = uav1ExpResConf
uav1ConfigParameters.hasName = "UaV1ConfigParameters"
uav1ConfigParameters.hasDescription = "descr-a"
uav1ConfigParameters.hasConfigParametersID = "UaV1ConfParamID"
uav1ConfigParameters.hasConfigParametersMinValue = 3.0
uav1ConfigParameters.hasConfigParametersMaxValue = 4.0
# uav1ConfigParameters.resourceId = "UaV1Id"
uav1ConfigParameters.save

ugv1ConfigParameters = SAMANT::ConfigParameters.for("urn:ugv1+config+parameters+test".to_sym)
ugv1ConfigParameters.hasExperimentResourceConfig = ugv1ExpResConf
ugv1ConfigParameters.hasName = "UgV1ConfigParameters"
ugv1ConfigParameters.hasDescription = "descr-b"
ugv1ConfigParameters.hasConfigParametersID = "UgV1ConfParamID"
ugv1ConfigParameters.hasConfigParametersMinValue = 2.0
ugv1ConfigParameters.hasConfigParametersMaxValue = 5.0
# ugv1ConfigParameters.resourceId = "UgV1Id"
ugv1ConfigParameters.save

auv1ConfigParameters = SAMANT::ConfigParameters.for("urn:auv1+config+parameters+test".to_sym)
auv1ConfigParameters.hasExperimentResourceConfig = auv1ExpResConf
auv1ConfigParameters.hasName = "Auv1ConfigParameters"
auv1ConfigParameters.hasDescription = "descr-c"
auv1ConfigParameters.hasConfigParametersID = "AuV1ConfParamID"
auv1ConfigParameters.hasConfigParametersMinValue = 1.0
auv1ConfigParameters.hasConfigParametersMaxValue = 6.0
# auv1ConfigParameters.resourceId = "AuV1Id"
auv1ConfigParameters.save

uav1Lease = SAMANT::Lease.for("urn:uav1+lease+test".to_sym)
uav1Lease.hasReservationState = SAMANT::UNALLOCATED
uav1Lease.startTime = Time.parse("2016-04-01 23:00:00 +0300")
uav1Lease.expirationTime = Time.parse("2017-03-15 23:00:00 +0300")
uav1Lease.hasID = "UaV1LeaseID"
uav1Lease.save

ugv1Lease = SAMANT::Lease.for("urn:ugv1+lease+test".to_sym)
ugv1Lease.hasReservationState = SAMANT::ALLOCATED
ugv1Lease.startTime = Time.parse("2016-05-02 23:00:00 +0300")
ugv1Lease.expirationTime = Time.parse("2017-04-16 23:00:00 +0300")
ugv1Lease.hasID = "UgV1LeaseID"
ugv1Lease.save

auv1Lease = SAMANT::Lease.for("urn:auv1+lease+test".to_sym)
auv1Lease.hasReservationState = SAMANT::PROVISIONED
auv1Lease.startTime = Time.parse("2016-06-03 23:00:00 +0300")
auv1Lease.expirationTime = Time.parse("2017-05-17 23:00:00 +0300")
auv1Lease.hasID = "AuV1LeaseID"
auv1Lease.save

uav1HealthInformation = SAMANT::HealthInformation.for("urn:uav1+health+information+test".to_sym)
uav1HealthInformation.hasGeneralHealthStatus = SAMANT::GENERALOK
uav1HealthInformation.isUpdated = "2016-12-12 04:00:00"
uav1HealthInformation.save

ugv1HealthInformation = SAMANT::HealthInformation.for("urn:ugv1+health+information+test".to_sym)
ugv1HealthInformation.hasGeneralHealthStatus = SAMANT::GENERALUNKNOWN
ugv1HealthInformation.isUpdated = "2017-12-12 04:00:00"
ugv1HealthInformation.save

auv1HealthInformation = SAMANT::HealthInformation.for("urn:auv1+health+information+test".to_sym)
auv1HealthInformation.hasGeneralHealthStatus = SAMANT::GENERALWARNING
auv1HealthInformation.isUpdated = "2015-12-12 04:00:00"
auv1HealthInformation.save

ifr1 = SAMANT::WiredInterface.for("urn:uuid:interface+1+wired+uav1:eth0".to_sym)
ifr1.hasComponentID = "urn:uuid:interface+1+wired+uav1:eth0"
ifr1.hasComponentName = "uav1:eth0"
ifr1.hasRole = "experimental"

ifr2 = SAMANT::WirelessInterface.for("urn:uuid:interface+2+wireless+ugv1:bt0".to_sym)
ifr2.hasComponentID = "urn:uuid:interface+2+wireless+ugv1:bt0"
ifr2.hasComponentName = "ugv1:bt0"
ifr2.hasRole = "experimental"

ifr3 = SAMANT::WirelessInterface.for("urn:uuid:interface+3+wireless+auv1:ble0".to_sym)
ifr3.hasComponentID = "urn:uuid:interface+3+wireless+auv1:ble0"
ifr3.hasComponentName = "auv1:ble0"
ifr3.hasRole = "experimental"

uav1 = SAMANT::UxV.for("urn:UaV1".to_sym)
uav1.hasHealthStatus = SAMANT::SHUTDOWN
uav1.isResourceOf = uavTestbed
uav1.hasResourceStatus = SAMANT::BOOKED
uav1.where << uav1Point3D
uav1.hasConfigParameters = uav1ConfigParameters
uav1.hasHealthInformation = uav1HealthInformation
uav1.hasUxVType = SAMANT::UAV
uav1.hasSensorSystem = auv1MultiSensor
uav1.hasLease = uav1Lease
uav1.resourceId = "UaV1_FLEXUS"
uav1.hasName = "UaV1"
uav1.hasStatusMessage = "UaVsaysHello"
uav1.hasDescription = "abcd"
uav1.hasInterface << ifr1
ifr1.isInterfaceOf = uav1
ifr1.save

# add sensors to UxV
uaV1MultiSensor_list = SAMANT::System.find(:all, :conditions => { :hasID => "UaV1MS345"} )
uaV1MultiSensor = uaV1MultiSensor_list[0]
uav1.hasSensorSystem = uaV1MultiSensor

uav1.save
uavTestbed.hasResource << uav1
uavTestbed.save

ugv1 = SAMANT::UxV.for("urn:UgV1".to_sym)
ugv1.hasHealthStatus = SAMANT::OK
ugv1.isResourceOf = ugvTestbed
ugv1.hasResourceStatus = SAMANT::SLEEPMODE
ugv1.where << ugv1Point3D
ugv1.hasConfigParameters = ugv1ConfigParameters
ugv1.hasHealthInformation = ugv1HealthInformation
ugv1.hasUxVType = SAMANT::UGV
ugv1.hasSensorSystem = auv1MultiSensor
ugv1.hasLease = ugv1Lease
ugv1.resourceId = "UgV1_VENAC"
ugv1.hasName = "UgV1"
ugv1.hasStatusMessage = "UgVsaysHello"
ugv1.hasDescription = "abcde"
ugv1.hasInterface << ifr2
ifr2.isInterfaceOf = ugv1
ifr2.save

# add sensors to UxV
ugv1MultiSensor_list = SAMANT::System.find(:all, :conditions => { :hasID => "UgV1MS345"} )
ugv1MultiSensor = ugv1MultiSensor_list[0]
ugv1.hasSensorSystem = ugv1MultiSensor

ugv1.save
ugvTestbed.hasResource << ugv1
ugvTestbed.save

auv1 = SAMANT::UxV.for("urn:AuV1".to_sym)
auv1.hasHealthStatus = SAMANT::WARNING
auv1.isResourceOf = auvTestbed
auv1.hasResourceStatus = SAMANT::RELEASED
auv1.where << auv1Point3D
auv1.hasConfigParameters = auv1ConfigParameters
auv1.hasHealthInformation = auv1HealthInformation
auv1.hasUxVType = SAMANT::AUV
auv1.hasSensorSystem = auv1MultiSensor
auv1.hasLease = auv1Lease
auv1.resourceId = "AuV1_ALTUS"
auv1.hasName = "AuV1"
auv1.hasStatusMessage = "AuVsaysHello"
auv1.hasDescription = "abcdef"
auv1.hasInterface << ifr3
ifr3.isInterfaceOf = auv1
ifr3.save

# add sensors to UxV
auv1MultiSensor_list = SAMANT::System.find(:all, :conditions => { :hasID => "UaV1MS345"} )
auv1MultiSensor = auv1MultiSensor_list[0]
auv1.hasSensorSystem = auv1MultiSensor

auv1.save
auvTestbed.hasResource << auv1
auvTestbed.save

dimitris = SAMANT::Person.for("urn:ddechouniotis".to_sym)
dimitris.hasUserSettings = dimitrisSettings
dimitris.usesTestbed = uavTestbed
dimitris.hasEmail = "dimitris@rawfie.com"
dimitris.hasFirstName = "Dimitris"
dimitris.hasSurname = "Dechouniotis"
dimitris.hasPassword = "password"
dimitris.hasUserName = "dimitris"
dimitris.hasUserID = "userid1"
dimitris.isSuperUser = false
dimitris.lastLogin = "2016-11-11 03:00:00"
dimitris.save

nikos = SAMANT::Person.for("urn:nkalatzis".to_sym)
nikos.hasUserSettings = nikosSettings
nikos.usesTestbed = ugvTestbed
nikos.hasEmail = "nikos@rawfie.com"
nikos.hasFirstName = "Nikos"
nikos.hasSurname = "Kalatzis"
nikos.hasPassword = "password"
nikos.hasUserName = "nikos"
nikos.hasUserID = "userid2"
nikos.isSuperUser = false
nikos.lastLogin = "2016-12-12 03:00:00"
nikos.save

marios = SAMANT::Person.for("urn:mavgeris".to_sym)
marios.hasUserSettings = mariosSettings
marios.usesTestbed = auvTestbed
marios.hasEmail = "marios@rawfie.com"
marios.hasFirstName = "Marios"
marios.hasSurname = "Avgeris"
marios.hasPassword = "password"
marios.hasUserName = "nikos"
marios.hasUserID = "userid3"
marios.isSuperUser = true
marios.lastLogin = "2016-10-10 03:00:00"
marios.save