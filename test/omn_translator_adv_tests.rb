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


    def test_translate_to_ttl_adv
      puts '****** test_translate_to_ttl_adv ******'

      xmlrspec =   '<?xml version="1.0"?>
  <!-- Resources at AM:
	URN: unspecified_AM_URN
	URL: http://vnews.netmode.ntua.gr:8001
 -->

<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ol="http://nitlab.inf.uth.gr/schema/sfa/rspec/1" xmlns:omf="http://schema.mytestbed.net/sfa/rspec/1" type="advertisement" xsi:schemaLocation="http://www.geni.net/resources/rspec/3 http://www.geni.net/resources/rspec/3/ad.xsd http://nitlab.inf.uth.gr/schema/sfa/rspec/1 http://nitlab.inf.uth.gr/schema/sfa/rspec/1/ad-reservation.xsd" generated="2017-01-06T11:37:54+02:00" expires="2017-01-06T11:47:54+02:00">
  <node component_id="urn:publicid:IDN+omf:netmode+node+node1" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node1" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node1:eth0" component_name="node1:eth0" role="control">
      <ip address="10.0.0.1" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node1:wlan0" component_name="node1:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node1:wlan1" component_name="node1:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979529" longitude="23.782769">
      <ol:position_3d x="744411.119" y="4207197.836" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node2" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node2" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node2:eth0" component_name="node2:eth0" role="control">
      <ip address="10.0.0.2" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node2:wlan0" component_name="node2:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node2:wlan1" component_name="node2:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979461" longitude="23.78277">
      <ol:position_3d x="744411.432" y="4207190.292" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node3" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node3" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node3:eth0" component_name="node3:eth0" role="control">
      <ip address="10.0.0.3" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node3:wlan0" component_name="node3:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node3:wlan1" component_name="node3:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979392" longitude="23.782769">
      <ol:position_3d x="744411.573" y="4207182.631" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node4" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node4" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node4:eth0" component_name="node4:eth0" role="control">
      <ip address="10.0.0.4" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node4:wlan0" component_name="node4:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node4:wlan1" component_name="node4:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979524" longitude="23.782855">
      <ol:position_3d x="744418.69" y="4207197.507" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node5" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node5" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node5:eth0" component_name="node5:eth0" role="control">
      <ip address="10.0.0.5" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node5:wlan0" component_name="node5:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node5:wlan1" component_name="node5:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979456" longitude="23.782861">
      <ol:position_3d x="744419.443" y="4207189.976" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node6" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node6" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node6:eth0" component_name="node6:eth0" role="control">
      <ip address="10.0.0.6" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node6:wlan0" component_name="node6:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node6:wlan1" component_name="node6:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979396" longitude="23.782855">
      <ol:position_3d x="744419.115" y="4207183.301" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node7" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node7" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node7:eth0" component_name="node7:eth0" role="control">
      <ip address="10.0.0.7" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node7:wlan0" component_name="node7:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node7:wlan1" component_name="node7:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979529" longitude="23.78294">
      <ol:position_3d x="744426.141" y="4207198.285" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node8" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node8" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node8:eth0" component_name="node8:eth0" role="control">
      <ip address="10.0.0.8" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node8:wlan0" component_name="node8:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node8:wlan1" component_name="node8:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979464" longitude="23.782939">
      <ol:position_3d x="744426.268" y="4207191.069" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node9" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node9" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node9:eth0" component_name="node9:eth0" role="control">
      <ip address="10.0.0.9" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node9:wlan0" component_name="node9:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node9:wlan1" component_name="node9:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979396" longitude="23.782933">
      <ol:position_3d x="744425.967" y="4207183.506" z="159.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node10" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node10" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node10:eth0" component_name="node10:eth0" role="control">
      <ip address="10.0.0.10" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node10:wlan0" component_name="node10:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node10:wlan1" component_name="node10:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979503" longitude="23.78277">
      <ol:position_3d x="744411.293" y="4207194.953" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node11" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node11" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node11:eth0" component_name="node11:eth0" role="control">
      <ip address="10.0.0.11" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node11:wlan0" component_name="node11:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node11:wlan1" component_name="node11:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979486" longitude="23.782771">
      <ol:position_3d x="744411.437" y="4207193.069" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node12" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node12" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node12:eth0" component_name="node12:eth0" role="control">
      <ip address="10.0.0.12" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node12:wlan0" component_name="node12:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node12:wlan1" component_name="node12:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.97935" longitude="23.78302">
      <ol:position_3d x="744433.763" y="4207178.629" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node13" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node13" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node13:eth0" component_name="node13:eth0" role="control">
      <ip address="10.0.0.13" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node13:wlan0" component_name="node13:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node13:wlan1" component_name="node13:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979496" longitude="23.782793">
      <ol:position_3d x="744413.337" y="4207194.237" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node14" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node14" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node14:eth0" component_name="node14:eth0" role="control">
      <ip address="10.0.0.14" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node14:wlan0" component_name="node14:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node14:wlan1" component_name="node14:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979517" longitude="23.78284">
      <ol:position_3d x="744417.396" y="4207196.691" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node15" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node15" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node15:eth0" component_name="node15:eth0" role="control">
      <ip address="10.0.0.15" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node15:wlan0" component_name="node15:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node15:wlan1" component_name="node15:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.97933" longitude="23.78278">
      <ol:position_3d x="744412.746" y="4207175.779" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node16" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node16" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node16:eth0" component_name="node16:eth0" role="control">
      <ip address="10.0.0.16" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node16:wlan0" component_name="node16:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node16:wlan1" component_name="node16:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.97937" longitude="23.78295">
      <ol:position_3d x="744427.547" y="4207180.665" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node17" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node17" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node17:eth0" component_name="node17:eth0" role="control">
      <ip address="10.0.0.17" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node17:wlan0" component_name="node17:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node17:wlan1" component_name="node17:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979491" longitude="23.782826">
      <ol:position_3d x="744416.252" y="4207193.768" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node18" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node18" exclusive="true">
    <available now="true"/>
    <hardware_type name="alix3d2"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node18:eth0" component_name="node18:eth0" role="control">
      <ip address="10.0.0.18" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node18:wlan0" component_name="node18:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node18:wlan1" component_name="node18:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979518" longitude="23.782893">
      <ol:position_3d x="744422.048" y="4207196.941" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node19" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node19" exclusive="true">
    <available now="true"/>
    <hardware_type name="Intel Atom"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node19:eth0" component_name="node19:eth0" role="control">
      <ip address="10.0.0.19" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node19:wlan0" component_name="node19:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node19:wlan1" component_name="node19:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979474" longitude="23.782835">
      <ol:position_3d x="744417.099" y="4207191.905" z="157.34"/>
    </location>
  </node>
  <node component_id="urn:publicid:IDN+omf:netmode+node+node20" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node20" exclusive="true">
    <available now="true"/>
    <hardware_type name="Intel Atom"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node20:eth0" component_name="node20:eth0" role="control">
      <ip address="10.0.0.20" type="ipv4" netmask="255.255.255.0"/>
    </interface>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node20:wlan0" component_name="node20:wlan0" role="experimental"/>
    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node20:wlan1" component_name="node20:wlan1" role="experimental"/>
    <location city="Athens" country="Greece" latitude="37.979499" longitude="23.782812">
      <ol:position_3d x="744414.996" y="4207194.619" z="157.34"/>
    </location>
  </node>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+1" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="1" frequency="2.412GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+2" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="2" frequency="2.417GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+3" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="3" frequency="2.422GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+4" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="4" frequency="2.427GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+5" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="5" frequency="2.432GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+6" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="6" frequency="2.437GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+7" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="7" frequency="2.442GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+8" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="8" frequency="2.447GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+9" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="9" frequency="2.452GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+10" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="10" frequency="2.457GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+11" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="11" frequency="2.462GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+12" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="12" frequency="2.467GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+13" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="13" frequency="2.472GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+36" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="36" frequency="5.180GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+40" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="40" frequency="5.200GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+44" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="44" frequency="5.220GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+48" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="48" frequency="5.240GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+52" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="52" frequency="5.260GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+56" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="56" frequency="5.280GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+60" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="60" frequency="5.300GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+64" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="64" frequency="5.220GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+100" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="100" frequency="5.500GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+104" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="104" frequency="5.520GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+108" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="108" frequency="5.540GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+112" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="112" frequency="5.560GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+116" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="116" frequency="5.580GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+120" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="120" frequency="5.600GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+124" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="124" frequency="5.620GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+128" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="128" frequency="5.640GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+132" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="132" frequency="5.660GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+136" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="136" frequency="5.680GHz"/>
  <ol:channel component_id="urn:publicid:IDN+omf:netmode+channel+140" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="140" frequency="5.700GHz"/>
</rspec>'

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


