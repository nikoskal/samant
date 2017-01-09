require 'rdf/do'
require 'do_sqlite3'
require_relative '../omn-models/resource.rb'
require_relative '../omn-models/omn'
require_relative '../omn-models/lifecycle'
require_relative '../omn-models/wireless'

# $repository = Spira.repository = RDF::Repository.new
#$repository = Spira.repository = RDF::DataObjects::Repository.new uri: "sqlite3:test.db"
require_relative '../samant_models/sensor.rb'
require_relative '../samant_models/uxv.rb'

=begin
node1 = Semantic::Node.for(:node1)

athens = Semantic::Location.for(:Athens)
athens.x= 58.76
athens.y = 42.97
athens.save!

ip1 = Semantic::IPAddress.for(:public_ip)
ip1.address = "192.168.12.1"
ip1.isIPAddressOf = node1
ip1.save!

ip2 = Semantic::IPAddress.for(:private_ip)
ip2.address = "192.168.12.123"
ip2.isIPAddressOf = node1
ip2.save!

link1 = Semantic::Link.for(:link1)
link1.save!

interface1 = Semantic::Interface.for(:interface1)
interface1.isInterfaceOf = node1
interface1.macAddress = "5e-c1-56-d9-db-2a"
interface1.save!

interface2 = Semantic::Interface.for(:interface2)
interface2.isInterfaceOf = node1
interface2.macAddress = "5e-c1-56-d9-db-2b"
interface2.save!

account1 = Semantic::Account.for(:nil_account) # STUD
account1.credentials = Semantic::Credentials.for(:creds1, {:id => :usrd, :password => :psswrd})
account1.save!

node1.hasInterface = [interface1, interface2]
node1.isAvailable = true
node1.isExclusive = true
node1.hasIPAddress << ip1
node1.hasIPAddress << ip2
node1.hasLocation = athens
node1.hasSliceID = "urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
node1.save!

n2 = Semantic::Node.for("urn:publicid:IDN+omf:nitos.outdoor+node+node0012".to_sym)
n2.hasLocation = athens
n2.hasComponentID = RDF::URI.new("urn:publicid:IDN+omf:nitos.outdoor+node+node0012")
n2.hasSliceID = "urn:publicid:IDN+omf:netmode+account+__default__"  #"urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
n2.isAvailable = true
n2.isExclusive = true
n2.hasInterface << interface1
n2.save!

######################################################################################

mc1 = Semantic::MicroController.for(:NiosII)
mc1.hasComponentID = RDF::URI.new('CPU/A/610')
mc1.hasComponentName = "Altera Nios II 32-bit"
mc1.save

rsc1 = Semantic::Resource.for(:StratixGX)
rsc1.hasID = "FPGA111"
rsc1.creator = "Altera"
rsc1.isVirtualized = true
rsc1.hasComponent << mc1
rsc1.hasSliceID = "urn:publicid:IDN+omf:netmode+account+__default__"
rsc1.save

node1.parent = rsc1
node1.save!

rsc2 = Semantic::Resource.for(:Arria10)
rsc2.hasID = "FPG222"
rsc2.creator = "Altera"
rsc2.isVirtualized = false
rsc2.hasSliceID = "urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
rsc2.save

rsc3 = Semantic::Resource.for(:CycloneV)
rsc3.hasID = "FPG333"
rsc3.creator = "Altera"
rsc3.isVirtualized = true
rsc3.hasSliceID = "urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
rsc3.save

grp1 = Semantic::Group.for(:GroupA)
grp1.hasURI = RDF::URI.new('FPGA/B/00')
grp1.hasResource << rsc1
grp1.hasResource << rsc2
grp1.save

st3 = Semantic::State.for(:Active)
st3.hasStateName = Semantic::Active.new
st3.save

st2 = Semantic::State.for(:Success)
st2.hasStateName = Semantic::Success.new
st2.hasNext = st3
st2.save

st1 = Semantic::State.for(:Pending)
st1.hasStateName = Semantic::Pending.new
st1.hasNext = st2
st1.save

# otan to vazeis etsi krataei mono to urn:uuid:2241fb1d-87a7-44b6-acf8-381f78549153
l1 = Semantic::Lease.for("urn:uuid:2241fb1d-87a7-44b6-acf8-381f78549153".to_sym)
l1.hasID = "uuid:2241fb1d-87a7-44b6-acf8-381f78549153"
l1.isReservationOf << node1
l1.hasState = st1
l1.startTime = "2015-12-11T20:00:00Z"
l1.expirationTime = "2017-12-11T20:00:05Z"
l1.hasSliceID = "urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
l1.save!

# puts "!!!!!!! L1L1L1" + l1.to_uri.inspect

l2 = Semantic::Lease.for(:lease2)
l2.hasID = "lease2-efgh"
l2.isReservationOf << node1
l2.startTime = "2015-12-11T20:00:00Z"
l2.expirationTime = "2017-12-11T20:00:05Z"
l2.hasState = st2
l2.hasSliceID = "urn:publicid:IDN+fed4fire:global:netmode1+slice+samant_test"
l2.save

=end
#l3 = Semantic::Lease.for(:lease3)
#l3.hasID = "lease2-efgh"
#l3.isReservationOf << rsc1
#l3.hasState = st3
#l3.hasSliceID = "urn:publicid:IDN+omf:netmode+account+__default__"
#l3.save