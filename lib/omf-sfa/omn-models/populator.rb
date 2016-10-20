require_relative '../omn-models/resource.rb'
require_relative '../omn-models/omn'
require_relative '../omn-models/lifecycle'
require_relative '../omn-models/wireless'

$repository = Spira.repository = RDF::Repository.new

node1 = Semantic::Node.for(:node1)

athens = Semantic::Location.for(:Athens)
athens.x= 58.76
athens.y = 42.97
athens.save!

ip1 = Semantic::IPAddress.for(:public_ip)
ip1.address = "192.168.12.1"
ip1.isIPAddressOf = node1
ip1.save!

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
node1.hasLocation = athens
node1.save!

n2 = Semantic::Node.for(:node2)
n2.hasLocation = athens
n2.isAvailable = true
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
rsc1.save

rsc2 = Semantic::Resource.for(:Arria10)
rsc2.hasID = "FPG222"
rsc2.creator = "Altera"
rsc2.isVirtualized = false
rsc2.save

rsc3 = Semantic::Resource.for(:CycloneV)
rsc3.hasID = "FPG333"
rsc3.creator = "Altera"
rsc3.isVirtualized = true
rsc3.save

grp1 = Semantic::Group.for(:GroupA)
grp1.hasURI = RDF::URI.new('FPGA/B/00')
grp1.hasResource << rsc1
grp1.hasResource << rsc2
grp1.save

st2 = Semantic::State.for(:Success)
st2.hasStateName = Semantic::Success.new
st2.save

st1 = Semantic::State.for(:Pending)
st1.hasStateName = Semantic::Pending.new
st1.hasNext = st2
st1.save

l1 = Semantic::Lease.for(:lease1)
l1.hasID = "lease1-abcd"
l1.isReservationOf << grp1
l1.isReservationOf << rsc3
l1.hasState = st1
l1.save