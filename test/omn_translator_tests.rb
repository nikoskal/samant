require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require 'tempfile'



class Omn_translator


    # from rpsec to omn
  def self.translate_rspec_omn(xmlrspec)

    puts ' translate xmlrspec:' + xmlrspec
    puts
    # puts 'translate rspec:'+type+" to omn"

    file = Tempfile.new('beforeTrans')
    file.write(xmlrspec)

    # puts "file created"
    # puts "filename: "+file.path
    file.rewind

    # puts "read file:" + file.read()
    # file.rewind
    command_name = "java -jar omnlib-jar-with-dependencies.jar -o ttl -i #{file.path}"
    puts "call java cmd: " +command_name
    result  = system(command_name)
  end


  def self.translate_omn_rspec(omn)

    puts 'translate omn:' + omn
    puts
    # puts 'translate rspec:'+type+" to omn"

    file = Tempfile.new('beforeTrans')
    file.write(omn)

    # puts "file created"
    # puts "filename: "+file.path
    file.rewind

    # puts "read file:" + file.read()
    # file.rewind
    command_name = "java -jar omnlib-jar-with-dependencies.jar -o request -i #{file.path}"
    puts "call java cmd: " +command_name
    result  = system(command_name)
  end

end






class OmnTranslatorTests < Minitest::Unit::TestCase

  def setup
    # @blog = Blog.new
  end


    def test_translate_to_ttl_request
    puts '****** test_translate_to_ttl ******'

    xmlrspec =   '<?xml version="1.0"?>
<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ol="http://nitlab.inf.uth.gr/schema/sfa/rspec/1" xmlns:omf="http://schema.mytestbed.net/sfa/rspec/1" type="advertisement" xsi:schemaLocation="http://www.geni.net/resources/rspec/3 http://www.geni.net/resources/rspec/3/ad.xsd http://nitlab.inf.uth.gr/schema/sfa/rspec/1 http://nitlab.inf.uth.gr/schema/sfa/rspec/1/ad-reservation.xsd" generated="2013-12-09T17:13:36+02:00" expires="2013-12-09T17:23:36+02:00">
 <ol:lease id="8749d9cc-2a0c-452d-84fe-5601800cb55f" valid_from="2013-12-09T17:11:13+02:00" valid_until="2013-12-09T18:11:13+02:00"/>
 <ol:lease id="eaba325f-27b8-44aa-baa2-dd4945c142cd" valid_from="2013-12-09T18:11:13+02:00" valid_until="2013-12-09T19:11:13+02:00"/>
 <ol:channel component_id="urn:publicid:IDN+omf:nitos+ol:channel+1" component_manager_id="urn:publicid:IDN+omf:nitos+authority+am" component_name="1" frequency="2.412GHZ"/>
 <node component_id="urn:publicid:IDN+omf:nitos.outdoor+node+node0" component_manager_id="urn:publicid:IDN+omf:nitos+authority+am" component_name="node0" exclusive="true">
   <available now="true"/>
   <interface component_id="urn:publicid:IDN+omf:nitos.outdoor+interface+node0:if0" component_name="node0:if0">
     <ip address="10.0.1.0" ip_type="ipv4" netmask="255.255.255.0"/>
   </interface>
   <ol:lease_ref id_ref="8749d9cc-2a0c-452d-84fe-5601800cb55f"/>
 </node>
 <node component_id="urn:publicid:IDN+omf:nitos.outdoor+node+node1" component_manager_id="urn:publicid:IDN+omf:nitos+authority+am" component_name="node1" exclusive="true">
   <available now="true"/>
   <interface component_id="urn:publicid:IDN+omf:nitos.outdoor+interface+node1:if0" component_name="node1:if0">
     <ip address="10.0.1.1" ip_type="ipv4" netmask="255.255.255.0"/>
   </interface>
   <ol:lease_ref id_ref="8749d9cc-2a0c-452d-84fe-5601800cb55f"/>
   <ol:lease_ref id_ref="eaba325f-27b8-44aa-baa2-dd4945c142cd"/>
 </node>
</rspec>'

    # translate = Omn_translator.new()

    ttl = Omn_translator.translate_rspec_omn(xmlrspec.delete("\n"))
    puts ttl

  end





  def test_translate_to_rspec_adv
    puts '****** test_translate_to_rspec ******'
    ttl ='<urn:publicid:IDN+omf:nitos.outdoor+node+node0012>
        <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
                "node0012" .

<urn:uuid:4704e6b9-3581-4309-bda7-4b9d172f1561>
        a       <http://open-multinet.info/ontology/omn-lifecycle#Lease> ;
        <http://open-multinet.info/ontology/omn-lifecycle#expirationTime>
                "2016-10-11T20:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
        <http://open-multinet.info/ontology/omn-lifecycle#startTime>
                "2016-10-10T19:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .

<http://open-multinet.info/example#nikosk>
        a       <http://open-multinet.info/ontology/omn-resource#Node> ;
        <http://www.w3.org/2000/01/rdf-schema#label>
                "nikosk" ;
        <http://open-multinet.info/ontology/omn#isResourceOf>
                <urn:uuid:7f397dc7-fafb-4c1d-a1ca-d6f5a95c6fe4> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasComponentID>
                "urn:publicid:IDN+omf:nitos.outdoor+node+node0012"^^<http://www.w3.org/2001/XMLSchema#anyURI> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasID>
                "nikosk" ;
        <http://open-multinet.info/ontology/omn-lifecycle#implementedBy>
                <urn:publicid:IDN+omf:nitos.outdoor+node+node0012> ;
        <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
                <urn:publicid:IDN+omf:nitos+authority+cm> ;
        <http://open-multinet.info/ontology/omn-resource#isExclusive>
                true .

<urn:uuid:7f397dc7-fafb-4c1d-a1ca-d6f5a95c6fe4>
        a       <http://open-multinet.info/ontology/omn#Topology> , <http://open-multinet.info/ontology/omn-lifecycle#Request> ;
        <http://www.w3.org/2000/01/rdf-schema#label>
                "Request" ;
        <http://open-multinet.info/ontology/omn#hasResource>
                <http://open-multinet.info/example#nikosk> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasLease>
                <urn:uuid:4704e6b9-3581-4309-bda7-4b9d172f1561> .'


    rspec = Omn_translator.translate_omn_rspec(ttl.delete("\n"))
    puts rspec

  end




#   def test_translate_to_rspec_request
#     puts '****** test_translate_to_rspec ******'
#     ttl ='<urn:publicid:IDN+omf:nitos.outdoor+node+node0012>
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
#                 "node0012" .
#
# <urn:uuid:4704e6b9-3581-4309-bda7-4b9d172f1561>
#         a       <http://open-multinet.info/ontology/omn-lifecycle#Lease> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#expirationTime>
#                 "2016-10-11T20:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#startTime>
#                 "2016-10-10T19:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
#
# <http://open-multinet.info/example#nikosk>
#         a       <http://open-multinet.info/ontology/omn-resource#Node> ;
#         <http://www.w3.org/2000/01/rdf-schema#label>
#                 "nikosk" ;
#         <http://open-multinet.info/ontology/omn#isResourceOf>
#                 <urn:uuid:7f397dc7-fafb-4c1d-a1ca-d6f5a95c6fe4> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentID>
#                 "urn:publicid:IDN+omf:nitos.outdoor+node+node0012"^^<http://www.w3.org/2001/XMLSchema#anyURI> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasID>
#                 "nikosk" ;
#         <http://open-multinet.info/ontology/omn-lifecycle#implementedBy>
#                 <urn:publicid:IDN+omf:nitos.outdoor+node+node0012> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
#                 <urn:publicid:IDN+omf:nitos+authority+cm> ;
#         <http://open-multinet.info/ontology/omn-resource#isExclusive>
#                 true .
#
# <urn:uuid:7f397dc7-fafb-4c1d-a1ca-d6f5a95c6fe4>
#         a       <http://open-multinet.info/ontology/omn#Topology> , <http://open-multinet.info/ontology/omn-lifecycle#Request> ;
#         <http://www.w3.org/2000/01/rdf-schema#label>
#                 "Request" ;
#         <http://open-multinet.info/ontology/omn#hasResource>
#                 <http://open-multinet.info/example#nikosk> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasLease>
#                 <urn:uuid:4704e6b9-3581-4309-bda7-4b9d172f1561> .'
#
#
#     rspec = Omn_translator.translate_omn_rspec(ttl.delete("\n"))
#     puts rspec
#
#   end






end


