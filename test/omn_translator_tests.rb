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

  def test_translate_to_ttl
    puts '****** test_translate_to_ttl ******'

    xmlrspec =   '<?xml version="1.0"?>
    <rspec type="request" xmlns="http://www.geni.net/resources/rspec/3" xmlns:ol="http://nitlab.inf.uth.gr/schema/sfa/rspec/1" xmlns:omf="http://schema.mytestbed.net/sfa/rspec/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.geni.net/resources/rspec/3 http://www.geni.net/resources/rspec/3/request.xsd http://nitlab.inf.uth.gr/schema/sfa/rspec/1 http://nitlab.inf.uth.gr/schema/sfa/rspec/1/request-reservation.xsd">
    <ol:lease client_id="nikosk" valid_from="2016-10-10T19:00:00Z" valid_until="2016-10-11T20:00:00Z"/>
    <node component_id="urn:publicid:IDN+omf:nitos.outdoor+node+node0012" component_manager_id="urn:publicid:IDN+omf:nitos+authority+cm" component_name="node0012" exclusive="true" client_id="nikosk">
    <ol:lease_ref id_ref="nikosk"/>
    </node>
    </rspec>'

    # translate = Omn_translator.new()

    ttl = Omn_translator.translate_rspec_omn(xmlrspec.delete("\n"))
    puts ttl

  end


  def test_translate_to_rspec
    puts '****** test_translate_to_rspec ******'
    ttl ='<urn:uuid:fe603127-6445-4120-aae8-1cf8bcba3e07>
        a       <http://open-multinet.info/ontology/omn#Topology> , <http://open-multinet.info/ontology/omn-lifecycle#Request> ;
        <http://www.w3.org/2000/01/rdf-schema#label>
                "Request" ;
        <http://open-multinet.info/ontology/omn#hasResource>
                <http://open-multinet.info/example#nikosk> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasLease>
                <urn:uuid:2241fb1d-87a7-44b6-acf8-381f78549153> .
<urn:publicid:IDN+omf:nitos.outdoor+node+node0012>
        <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName>
                "node0012" .
<urn:uuid:2241fb1d-87a7-44b6-acf8-381f78549153>
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
                <urn:uuid:fe603127-6445-4120-aae8-1cf8bcba3e07> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasComponentID>
                "urn:publicid:IDN+omf:nitos.outdoor+node+node0012"^^<http://www.w3.org/2001/XMLSchema#anyURI> ;
        <http://open-multinet.info/ontology/omn-lifecycle#hasID>
                "nikosk" ;
        <http://open-multinet.info/ontology/omn-lifecycle#implementedBy>
                <urn:publicid:IDN+omf:nitos.outdoor+node+node0012> ;
        <http://open-multinet.info/ontology/omn-lifecycle#managedBy>
                <urn:publicid:IDN+omf:nitos+authority+cm> ;
        <http://open-multinet.info/ontology/omn-resource#isExclusive>
                true .'


    rspec = Omn_translator.translate_omn_rspec(ttl.delete("\n"))
    puts rspec

  end


end


