require 'data_objects'
require 'rdf/do'
require 'do_sqlite3'
$repository = Spira.repository = RDF::DataObjects::Repository.new uri: 'sqlite3:./test.db'
require_relative '../samant_models/sensor.rb'
require_relative '../samant_models/uxv.rb'

# Repopulate triplestore
RDF::Util::Logger.logger.parent.level = 'off'

sliver1 = SAMANT::Lease.for('urn:publicid:IDN+omf:netmode+sliver+375525ca-12ee-468c-9dd3-23603a7165c9'.to_sym)
sliver1.hasReservationState = SAMANT::ALLOCATED
sliver1.startTime = Time.parse('2017-03-01T19:00:00Z')
sliver1.expirationTime = Time.parse('2017-03-02T20:00:00Z')
sliver1.hasID = 'urn:publicid:IDN+omf:netmode+sliver+375525ca-12ee-468c-9dd3-23603a7165c9'
sliver1.hasSliceID = 'urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test'

#1111111111111111111111111

uav1MultiSensor = SAMANT::System.for('urn:uav1+multi+sensor'.to_sym)
uav1MultiSensor.hasID = 'UaV1MS345'
uav1MultiSensor.save

ifr1 = SAMANT::WiredInterface.for('urn:uuid:interface+1+wired+uav1:eth0'.to_sym)
ifr1.hasComponentID = 'urn:uuid:interface+1+wired+uav1:eth0'
ifr1.hasComponentName = 'uav1:eth0'
ifr1.hasRole = 'experimental'

uav1Point3D = SAMANT::Point3D.for('urn:uav+point3D'.to_sym)
uav1Point3D.lat = 5.5701e1
uav1Point3D.long = 1.2552e1
uav1Point3D.save

uav1 = SAMANT::UxV.for('urn:publicid:IDN+omf:netmode+node+UaV1'.to_sym)
uav1.hasResourceStatus = SAMANT::RELEASED
uav1.hasSliceID = 'urn:publicid:IDN+omf:netmode+account+__default__'
uav1.where << uav1Point3D
uav1.hasUxVType = SAMANT::UAV
uav1.hasSensorSystem = uav1MultiSensor
uav1.resourceId = 'UaV1_FLEXUS'
uav1.hasInterface << ifr1
ifr1.isInterfaceOf = uav1
ifr1.save
uav1.save

#2222222222222222222222222

auv1MultiSensor = SAMANT::System.for('urn:auv1+multi+sensor'.to_sym)
auv1MultiSensor.hasID = 'AuV1MS345'
auv1MultiSensor.save

ifr2 = SAMANT::WiredInterface.for('urn:uuid:interface+1+wired+auv1:eth0'.to_sym)
ifr2.hasComponentID = 'urn:uuid:interface+1+wired+auv1:eth0'
ifr2.hasComponentName = 'auv1:eth0'
ifr2.hasRole = 'experimental'

auv1Point3D = SAMANT::Point3D.for('urn:auv1+point3D'.to_sym)
auv1Point3D.lat = 2.1701e1
auv1Point3D.long = 9.355200000000001e1
auv1Point3D.save

auv1 = SAMANT::UxV.for('urn:publicid:IDN+omf:netmode+node+AuV1'.to_sym)
auv1.hasResourceStatus = SAMANT::RELEASED
auv1.hasSliceID = 'urn:publicid:IDN+omf:netmode+account+__default__'
auv1.where << auv1Point3D
auv1.hasUxVType = SAMANT::AUV
auv1.hasSensorSystem = auv1MultiSensor
auv1.resourceId = 'AuV1_ALTUS'
auv1.hasInterface << ifr2
ifr2.isInterfaceOf = auv1
ifr2.save
auv1.save

#33333333333333333333333

auv2MultiSensor = SAMANT::System.for('urn:auv2+multi+sensor'.to_sym)
auv2MultiSensor.hasID = 'AuV2MS345'
auv2MultiSensor.save

ifr3 = SAMANT::WiredInterface.for('urn:uuid:interface+1+wired+auv2:eth0'.to_sym)
ifr3.hasComponentID = 'urn:uuid:interface+1+wired+auv2:eth0'
ifr3.hasComponentName = 'auv2:eth0'
ifr3.hasRole = 'experimental'

auv2Point3D = SAMANT::Point3D.for('urn:auv2+point3D'.to_sym)
auv2Point3D.lat = 3.1701e1
auv2Point3D.long = 10.355200000000001e1
auv2Point3D.save

auv2 = SAMANT::UxV.for('urn:publicid:IDN+omf:netmode+node+AuV2'.to_sym)
auv2.hasResourceStatus = SAMANT::BOOKED
auv2.hasSliceID = 'urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test'
auv2.hasLease = sliver1
auv2.where << auv2Point3D
auv2.hasUxVType = SAMANT::AUV
auv2.hasSensorSystem = auv2MultiSensor
auv2.hasLease = sliver1
auv2.resourceId = 'AuV2_ALTUS'
auv2.hasInterface << ifr3
ifr3.isInterfaceOf = auv2
ifr3.save
auv2.save

#4444444444444444444444444

auv3MultiSensor = SAMANT::System.for('urn:auv3+multi+sensor'.to_sym)
auv3MultiSensor.hasID = 'AuV3MS345'
auv3MultiSensor.save

ifr4 = SAMANT::WiredInterface.for('urn:uuid:interface+1+wired+auv3:eth0'.to_sym)
ifr4.hasComponentID = 'urn:uuid:interface+1+wired+auv3:eth0'
ifr4.hasComponentName = 'auv3:eth0'
ifr4.hasRole = 'experimental'

auv3Point3D = SAMANT::Point3D.for('urn:auv3+point3D'.to_sym)
auv3Point3D.lat = 4.1701e1
auv3Point3D.long = 11.355200000000001e1
auv3Point3D.save

auv3 = SAMANT::UxV.for('urn:publicid:IDN+omf:netmode+node+AuV3'.to_sym)
auv3.hasResourceStatus = SAMANT::BOOKED
auv3.hasSliceID = 'urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test'
auv3.hasLease = sliver1
auv3.where << auv3Point3D
auv3.hasUxVType = SAMANT::AUV
auv3.hasSensorSystem = auv3MultiSensor
auv3.hasLease = sliver1
auv3.resourceId = 'AuV3_ALTUS'
auv3.hasInterface << ifr4
ifr4.isInterfaceOf = auv3
ifr4.save
auv3.save

sliver1.isReservationOf << auv2 << auv3
sliver1.save

#555555555555555555555555555

ugv1MultiSensor = SAMANT::System.for('urn:ugv1+multi+sensor'.to_sym)
ugv1MultiSensor.hasID = 'UgV1MS345'
ugv1MultiSensor.save

ifr5 = SAMANT::WirelessInterface.for('urn:uuid:interface+1+wired+ugv1:bt0'.to_sym)
ifr5.hasComponentID = 'urn:uuid:interface+1+wired+gv1:bt0'
ifr5.hasComponentName = 'gv1:bt0'
ifr5.hasRole = 'experimental'

ugv1Point3D = SAMANT::Point3D.for('urn:ugv1+point3D'.to_sym)
ugv1Point3D.lat = 4.1701e1
ugv1Point3D.long = 11.355200000000001e1
ugv1Point3D.save

ugv1 = SAMANT::UxV.for('urn:publicid:IDN+omf:netmode+node+UgV1'.to_sym)
ugv1.hasResourceStatus = SAMANT::RELEASED
ugv1.hasSliceID = 'urn:publicid:IDN+omf:netmode+account+__default__'
ugv1.where << ugv1Point3D
ugv1.hasUxVType = SAMANT::AUV
ugv1.hasSensorSystem = auv3MultiSensor
ugv1.resourceId = 'UgV1_ALTUS'
ugv1.hasInterface << ifr5
ifr5.isInterfaceOf = ugv1
ifr5.save
ugv1.save