require_relative '../omn-models/resource.rb'
require_relative '../omn-models/account'

$repository = Spira.repository = RDF::Repository.new

node1 = Semantic::Node.for(:node1)

athens = Semantic::Location.for(:Athens)
athens.x = 58.76
athens.y = 42.97
athens.save!

ip1 = Semantic::NetworkObject.for(:public_ip)
ip1.address = "192.168.12.1"
ip1.ipOf = node1
ip1.save!

link1 = Semantic::Link.for(:link1)
link1.available = true
link1.save!

interface1 = Semantic::Interface.for(:interface1)
interface1.interfaceOf = node1
interface1.properties << link1
interface1.macAddress = "5e-c1-56-d9-db-2a"
interface1.save!

interface2 = Semantic::Interface.for(:interface2)
interface2.interfaceOf = node1
interface2.macAddress = "5e-c1-56-d9-db-2b"
interface2.save!

account1 = Semantic::Account.for(:nil_account) # STUD
account1.credentials = Semantic::Credentials.for(:creds1, {:id => :usrd, :password => :psswrd})
account1.save!

node1.interfaces = [interface1, interface2]
node1.available = true
node1.exclusive = true
node1.ips << ip1
node1.location = athens
node1.managedBy = account1
node1.save!

n2 = Semantic::Node.for(:node2)
n2.location = athens
n2.available = true
n2.managedBy = account1
n2.interfaces << interface1
n2.save!