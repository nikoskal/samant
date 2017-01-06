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
    command_name = "java -jar omnlib-jar-with-dependencies.jar -o advertisement -i #{file.path}"
    puts "call java cmd: " +command_name
    result  = system(command_name)
  end

end





class OmnTranslatorTests < Minitest::Unit::TestCase

  def setup
    # @blog = Blog.new
  end




  def test_translate_to_rspec_adv
    puts '****** test_translate_to_rspec ******'
    ttl ='<urn:AuV1> a <http://open-multinet.info/ontology/omn-resource#Node>;
   <http://www.w3.org/2000/01/rdf-schema#label> "AuV1Id";
   <http://open-multinet.info/ontology/omn#isResourceOf> <urn:uuid:759da0fd-684e-4535-85bb-e400c3f2063b>;
   <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName> "AuV1Id";
   <http://open-multinet.info/ontology/omn-resource#isAvailable> true;
   <http://open-multinet.info/ontology/omn-resource#isExclusive> true .

  <urn:UaV1> a <http://open-multinet.info/ontology/omn-resource#Node>;
   <http://www.w3.org/2000/01/rdf-schema#label> "UaV1Id";
   <http://open-multinet.info/ontology/omn#isResourceOf> <urn:uuid:759da0fd-684e-4535-85bb-e400c3f2063b>;
   <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName> "UaV1Id";
   <http://open-multinet.info/ontology/omn-resource#isAvailable> false;
   <http://open-multinet.info/ontology/omn-resource#isExclusive> true .

  <urn:UgV1> a <http://open-multinet.info/ontology/omn-resource#Node>;
   <http://www.w3.org/2000/01/rdf-schema#label> "UgV1Id";
   <http://open-multinet.info/ontology/omn#isResourceOf> <urn:uuid:759da0fd-684e-4535-85bb-e400c3f2063b>;
   <http://open-multinet.info/ontology/omn-lifecycle#hasComponentName> "UgV1Id";
   <http://open-multinet.info/ontology/omn-resource#isAvailable> false;
   <http://open-multinet.info/ontology/omn-resource#isExclusive> true .

<urn:auv1+lease+test> a <http://open-multinet.info/ontology/omn-lifecycle#Lease>;
   <http://open-multinet.info/ontology/omn-lifecycle#expirationTime> "2017-05-17T23:00:00+03:00"^^<http://www.w3.org/2001/XMLSchema#dateTime>;
   <http://open-multinet.info/ontology/omn-lifecycle#startTime> "2016-06-03T23:00:00+03:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .

<urn:uav1+lease+test> a <http://open-multinet.info/ontology/omn-lifecycle#Lease>;
   <http://open-multinet.info/ontology/omn-lifecycle#expirationTime> "2017-03-15T22:00:00+02:00"^^<http://www.w3.org/2001/XMLSchema#dateTime>;
   <http://open-multinet.info/ontology/omn-lifecycle#startTime> "2016-04-01T23:00:00+03:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .

<urn:ugv1+lease+test> a <http://open-multinet.info/ontology/omn-lifecycle#Lease>;
   <http://open-multinet.info/ontology/omn-lifecycle#expirationTime> "2017-04-16T23:00:00+03:00"^^<http://www.w3.org/2001/XMLSchema#dateTime>;
   <http://open-multinet.info/ontology/omn-lifecycle#startTime> "2016-05-02T23:00:00+03:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .

<urn:uuid:759da0fd-684e-4535-85bb-e400c3f2063b> a <http://open-multinet.info/ontology/omn-lifecycle#Offering>;
   <http://www.w3.org/2000/01/rdf-schema#label> "Offering";
   <http://open-multinet.info/ontology/omn-lifecycle#hasLease> <urn:ugv1+lease+test>,
     <urn:uav1+lease+test>,
     <urn:auv1+lease+test>;
   <http://open-multinet.info/ontology/omn-lifecycle#hasResource> <urn:UaV1>,
     <urn:UgV1>,
     <urn:AuV1> .'


    rspec = Omn_translator.translate_omn_rspec(ttl.delete("\n"))
    puts rspec
  end


end



