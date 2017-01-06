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
    command_name = "java -jar omnlib-jar-with-dependencies.jar -o manifest -i #{file.path}"
    puts "call java cmd: " +command_name
    result  = system(command_name)
  end

end






class OmnTranslatorTests < Minitest::Unit::TestCase

  def setup
    # @blog = Blog.new
  end


    def test_translate_to_ttl_adv
      puts '****** test_translate_to_ttl_adv ******'

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
 </node></rspec>'

      # translate = Omn_translator.new()

      ttl = Omn_translator.translate_rspec_omn(xmlrspec.delete("\n"))
      puts ttl

    end





#   def test_translate_to_rspec_adv
#     puts '****** test_translate_to_rspec ******'
#     ttl ='[ a       <http://www.w3.org/2002/07/owl#NamedIndividual> , <http://open-multinet.info/ontology/omn-domain-wireless#Standard> ;
#   <http://www.w3.org/2000/01/rdf-schema#label>
#           "802.11a"
# ] .
#
# <urn:publicid:IDN+omf:nitos+authority+am>
#         a       <http://open-multinet.info/ontology/omn-domain-geni-fire#AMService> .
#
# <urn:publicid:IDN+omf:nitos+ol:channel+1>
#         a       <http://open-multinet.info/ontology/omn-domain-wireless#Channel> ;
#         <http://open-multinet.info/ontology/omn-domain-wireless#channelNum>
#                 1 ;
#         <http://open-multinet.info/ontology/omn-domain-wireless#supportsStandard>
#                 [ a       <http://www.w3.org/2002/07/owl#NamedIndividual> , <http://open-multinet.info/ontology/omn-domain-wireless#Standard> ;
#                   <http://www.w3.org/2000/01/rdf-schema#label>
#                           "802.11n"
#                 ] ;
#         <http://open-multinet.info/ontology/omn-domain-wireless#supportsStandard>
#                 [ a       <http://www.w3.org/2002/07/owl#NamedIndividual> , <http://open-multinet.info/ontology/omn-domain-wireless#Standard> ;
#                   <http://www.w3.org/2000/01/rdf-schema#label>
#                           "802.11g"
#                 ] ;
#         <http://open-multinet.info/ontology/omn-domain-wireless#supportsStandard>
#                 [ a       <http://www.w3.org/2002/07/owl#NamedIndividual> , <http://open-multinet.info/ontology/omn-domain-wireless#Standard> ;
#                   <http://www.w3.org/2000/01/rdf-schema#label>
#                           "802.11b"
#                 ] ;
#         <http://open-multinet.info/ontology/omn-domain-wireless#usesFrequency>
#                 <http://open-multinet.info/ontology/omn_wireless.owl#2.412GHZ> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
#                 <urn:publicid:IDN+omf:nitos+authority+am> .
#
# <urn:uuid:90ca1202-90ce-4310-a3b3-b86c451082ed>
#         a       <http://open-multinet.info/ontology/omn-resource#Interface> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentID>
#                 "urn:publicid:IDN+omf:nitos.outdoor+interface+node0:if0"^^<http://www.w3.org/2001/XMLSchema#anyURI> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
#                 "node0:if0"^^<http://www.w3.org/2001/XMLSchema#string> .
#
# <urn:publicid:IDN+omf:nitos.outdoor+node+node0>
#         a       <http://open-multinet.info/ontology/omn-resource#Node> ;
#         <http://www.w3.org/2000/01/rdf-schema#label>
#                 "node0"^^<http://www.w3.org/2001/XMLSchema#string> ;
#         <http://open-multinet.info/ontology/omn#isResourceOf>
#                 <urn:uuid:0ced6aab-7aec-40c4-8073-48969d9acdef> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
#                 "node0" ;
#         <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
#                 <urn:publicid:IDN+omf:nitos+authority+am> ;
#         <http://open-multinet.info/ontology/omn-resource#hasInterface>
#                 <urn:uuid:90ca1202-90ce-4310-a3b3-b86c451082ed> ;
#         <http://open-multinet.info/ontology/omn-resource#isAvailable>
#                 true ;
#         <http://open-multinet.info/ontology/omn-resource#isExclusive>
#                 true .
#
# <urn:uuid:6c4438ed-39be-424d-9691-9fd6e2190c57>
#         a       <http://open-multinet.info/ontology/omn-resource#Interface> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentID>
#                 "urn:publicid:IDN+omf:nitos.outdoor+interface+node1:if0"^^<http://www.w3.org/2001/XMLSchema#anyURI> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
#                 "node1:if0"^^<http://www.w3.org/2001/XMLSchema#string> .
#
# <urn:uuid:13c8e014-166a-49c6-b85b-36fddf6a1ee3>
#         a       <http://open-multinet.info/ontology/omn-lifecycle#Lease> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#expirationTime>
#                 "2013-12-09T16:11:13Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#startTime>
#                 "2013-12-09T15:11:13Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
#
# <urn:publicid:IDN+omf:nitos.outdoor+node+node1>
#         a       <http://open-multinet.info/ontology/omn-resource#Node> ;
#         <http://www.w3.org/2000/01/rdf-schema#label>
#                 "node1"^^<http://www.w3.org/2001/XMLSchema#string> ;
#         <http://open-multinet.info/ontology/omn#isResourceOf>
#                 <urn:uuid:0ced6aab-7aec-40c4-8073-48969d9acdef> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
#                 "node1" ;
#         <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
#                 <urn:publicid:IDN+omf:nitos+authority+am> ;
#         <http://open-multinet.info/ontology/omn-resource#hasInterface>
#                 <urn:uuid:6c4438ed-39be-424d-9691-9fd6e2190c57> ;
#         <http://open-multinet.info/ontology/omn-resource#isAvailable>
#                 true ;
#         <http://open-multinet.info/ontology/omn-resource#isExclusive>
#                 true .
#
# <urn:uuid:0ced6aab-7aec-40c4-8073-48969d9acdef>
#         a       <http://open-multinet.info/ontology/omn-lifecycle#Offering> ;
#         <http://www.w3.org/2000/01/rdf-schema#label>
#                 "Offering" ;
#         <http://open-multinet.info/ontology/omn#hasComponent>
#                 <urn:publicid:IDN+omf:nitos+ol:channel+1> ;
#         <http://open-multinet.info/ontology/omn#hasResource>
#                 <urn:publicid:IDN+omf:nitos.outdoor+node+node1> , <urn:publicid:IDN+omf:nitos.outdoor+node+node0> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#hasLease>
#                 <urn:uuid:2b99ee5f-e95e-4fc3-9019-3c9b20df8d2e> , <urn:uuid:13c8e014-166a-49c6-b85b-36fddf6a1ee3> .
#
# <urn:uuid:2b99ee5f-e95e-4fc3-9019-3c9b20df8d2e>
#         a       <http://open-multinet.info/ontology/omn-lifecycle#Lease> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#expirationTime>
#                 "2013-12-09T17:11:13Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
#         <http://open-multinet.info/ontology/omn-lifecycle#startTime>
#                 "2013-12-09T16:11:13Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .'
#
#
#     rspec = Omn_translator.translate_omn_rspec(ttl.delete("\n"))
#     puts rspec
#
#   end








end


