This directory contains the implementations of various Semantically Aware as well as SFA enabled APIs and services.

Semantic Aggregate Manager
=================


Prerequirements
---------------

You may skip this part if you already have ruby 2.0.0 and the libraries required, up and running in your system.

First, install rvm:
	
	$ curl https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer | bash -s stable

After installation just restart your terminal and type:
	
	$ type rvm | head -n 1

If it prints "rvm is a function" then everything is fine. 

Make sure you install ruby 2.0.0 version

	$ rvm install 2.0.0

Install xmlsec1, which is required by the am_server

	$ sudo apt-get install libxmlsec1-dev xmlsec1
	$ sudo apt-get install libsqlite3-dev
	$ gem install bundler


Installation
------------

The first step is to clone the SAM repository

    $ git clone -b omn/wip https://github.com/nikoskal/samant.git
    $ mv samant omf_sfa
    $ cd omf_sfa
    $ export OMF_SFA_HOME=`pwd`
    $ bundle install


Configuration
-------------

This file, OMF_SFA_HOME/etc/omf-sfa/omf-sfa-am.yaml, is the central configuration file of SAM.

	$ cd $OMF_SFA_HOME/etc/omf-sfa 
	$ nano omf-sfa-am.yaml
	
change domain to omf:TESTBED_NAME*

*replace TESTBED_NAME with your testbed's name. For instance, at NETMODE we use "netmode".


Semantic Graph Database & Ontologies
------------------------------------

Next you have to install the openrdf-sesame adaptor:

	$ wget https://netix.dl.sourceforge.net/project/sesame/Sesame%204/4.1.2/openrdf-sesame-4.1.2-sdk.tar.gz

Unzip the folder and deploy the openrdf-sesame.war and openrdf-workbench.war, located in the  openrdf-sesame-4.1.2/war folder. For the deployment you may use Apache Tomcat or any other known alternative of your choice.

Now you are ready to deploy the Semantic Graph Database. Request a copy of GraphDB 8 from here: 

	https://ontotext.com/products/graphdb/

Unfortunately we can not provide you with a direct download link, but one will be available to you shortly after filling the required fields. Make sure to download it "as a standanlone server".

When the download has finished, it is time to run the GraphDB instance. After unziping it,navigate to the downloaded folder and execute the following script.

	$ cd /bin
	$./graphdb

The GraphDB Workbench is available at port 7200 of your machine. Visit localhost:7200 and create a new repository with the default settings. Then, visit the openrdf-workbench (location depending on where the adapter is deployed) and create a New repository. In the dropdown list, select the "Remote RDF Store" option. After clicking "Next" you will be prompted to specify the "Sesame server locations". Use the url of the GraphDB Workbench. For ID and Title use "remote". For the "Remote repository ID" use the name of the repository you created with the GraphDB Workbench and then click "Create".

Now you should import the respective Ontologies. Firstly, download the Ontologies from 

	http://samant.lab.netmode.ntua.gr/documents 

Again, visit the GraphDB Workbench and click "Import" -> "RDF" -> "Local Files" and upload both of the downloaded files.

Congratulations, your repository is now created and connected to the adapter!


Relational Database
-------------------

Use the Rakefile to set up the relational database, where the authorization/authentication information is being stored.

	$ cd $OMF_SFA_HOME
	$ rake db:migrate

This will actually create an empty database based on the information defined on the configuration file.


Certificates
------------

The directory which holds the certificates is specified in the configuration file.
First we have to create a root self signed certificate for our testbed that will sign every other certificate we create.

	$ omf_cert.rb --email root@DOMAIN** -o root.pem --duration 50000000 create_root

*please replace DOMAIN with your tesbed's domain. For instance, at NETMODE testdbed, we use "netmode.ntua.gr".

Then you have to copy this file to the trusted roots directory (defined in the configuration file)
	

	$ mkdir ~/.omf
	$ mkdir ~/.omf/trusted_roots
	$ cp root.pem ~/.omf/trusted_roots

Now we have to create the certificate used by am_server and copy it to the corresponding directory. Please notice that we are using the root certificate, we have just created, in --root argument.
	
	$ omf_cert.rb -o am.pem --geni_uri URI:urn:publicid:IDN+omf:TESTBED_NAME*+user+am --email am@DOMAIN** --resource-id xmpp://147.102.13.123:5269@omf:TESTBED_NAME* --resource-type am_controller --root root.pem --duration 50000000 create_resource
	$ cp am.pem ~/.omf/

*replace TESTBED_NAME with your testbed's name. For instance, at NETMODE we use "netmode".
**once again, replace DOMAIN with your tesbed's domain. For instance, at NETMODE testdbed, we use "netmode.ntua.gr".

We also have to create a user certificate (for root user) for the various scripts to use. You can use this command to create certificates for any user you wish. .
	
	$ omf_cert.rb -o user_cert.pem --geni_uri URI:urn:publicid:IDN+omf:TESTBED_NAME*+user+root --email root@DOMAIN**  --user root --root root.pem --duration 50000000 create_user
	$ cp user_cert.pem ~/.omf/

*replace TESTBED_NAME with your testbed's name. For instance, at NETMODE we use "netmode".
**once again, replace DOMAIN with your tesbed's domain. For instance, at NETMODE testdbed, we use "netmode.ntua.gr".

Now open the above certificates with any text editor copy the private key at the bottom of the certificate (with the headings) create a new file (get the name of the private key from the corresponding configuration file) and paste the private key in this file. For example:
	
	$ vi user_cert.pem

copy something that looks like this

 \-----BEGIN RSA PRIVATE KEY-----
 MIIEowIBAAKCAQEA4Rbp2cdAsZ2147QgqnQUeA4y8KSCXYpcp+acVIBFecVT94EC
 D59l162wMb67tGSwSim3K59olN02A6beN46u ... aafh6gmHbDGx+j1UAo1bFtA
 kjYJDDXxhrU1yK/foHdT38v5TlGmSvbuubuWOskCJRoKkHfbOPlH
 \-----END RSA PRIVATE KEY-----

	$ vi user_cert.pkey 

and paste inside.

Repeat this process for the am.pem certificate (am.pem and am_key.pem). Also copy the am certificate to trusted_roots folder.
	
	$ cp am.pem ~/.omf/trusted_roots

Update the configuration file OMF_SFA_HOME/etc/omf-sfa/omf-sfa-am.yaml
	
	cert_chain_file: ~/omf_sfa/am.pem 
	private_key_file: ~/omf_sfa/am_key.pem 
	trusted_roots: ~/.omf/trusted_roots


Starting a Test SAM
------------------

To start a SAM instance (at port 443) from this directory, run the following:

    $ cd $OMF_SFA_HOME
    $ rvmsudo bundle exec ruby -I lib lib/omf-sfa/am/am_server.rb start -p 443

which should result into something like:

	DEBUG AMScheduler: initialize_event_scheduler
	DEBUG AMScheduler: Initial leases: [...]
	DEBUG AMScheduler: add_samant_lease_events_on_event_scheduler: lease: ...
	DEBUG AMScheduler: Existing jobs on event scheduler: 
	DEBUG AMScheduler: job: ...
	DEBUG AMScheduler: job: ...
	Thin web server (v1.6.0 codename Greek Yogurt)
	Maximum connections set to 1024
	Listening on 0.0.0.0:8001, CTRL+C to stop
	INFO XMPP::Communicator: Connecting to '...' ...
	Connected to the XMPP.
	INFO XMPP::Communicator: Connected
	DEBUG XMPP::Topic: New topic: ...
	DEBUG Auth::CertificateStore: Registering certificate for '...' - /C=US/ST=CA/O=ACME/OU=Roadrunner/CN=xmpp://10.0.0.200@omf:netmode/type=am_controller/...
	DEBUG OmfRc::ResourceFactory: 
	DEBUG XMPP::Topic: New topic: am_controller
	AM Resource Controller ready.
	DEBUG XMPP::Communicator: _create >> ... SUCCEED
	DEBUG XMPP::Communicator: _subscribe >> ... SUCCEED
	DEBUG XMPP::Communicator: _subscribe >> am_controller SUCCEED
	DEBUG Auth::CertificateStore: Registering certificate for '{:uuid=>"...", :geni=>"omf"}' - /C=US/ST=CA/O=ACME/OU=Roadrunner/CN=xmpp://10.0.0.200@omf:netmode/type=am_controller/...
	DEBUG XMPP::Topic: New topic: xmpp://am_controller@10.0.0.200
	DEBUG XML::Message: Found cert for 'xmpp://am_controller@10.0.0.200 - #<OmfCommon::Auth::Certificate subj=/C=US/ST=CA/O=ACME/OU=Roadrunner/CN=xmpp://10.0.0.200@omf:netmode/type=am_controller/...
	DEBUG XMPP::Topic: (am_controller) register handler for 'message'
	DEBUG XMPP::Communicator: publish >> am_controller SUCCEED
	DEBUG Auth::CertificateStore: Registering certificate for '{:uuid=>"...", :geni=>"omf"}' - /C=US/ST=CA/O=ACME/OU=Roadrunner/CN=xmpp://10.0.0.200@omf:netmode/type=am_controller/...
	DEBUG XMPP::Topic: (am_controller) Deliver message 'inform': ...
	DEBUG XMPP::Topic: (am_controller) Message type '[:inform, :message, :create_succeeded, :creation_ok]' (OmfCommon::Message::XML::Message:)
	DEBUG XMPP::Topic: (am_controller) Distributing message to '...'
	DEBUG XMPP::Topic: Existing topic: xmpp://am_controller@10.0.0.200


Populate the Database
---------------------

A json file that describes the resources is required. This file can contain either a single resource or more than one resources in the form of an array. A sample file is as follows. The description of each resource is in the form of filling specific values to the predefined properties of each resources. The set of the properties of each resource is defined in its model:

	{
	  "resources": {
	    "name": "netmode1",
	    "type": "uxv",
	    "authority": "samant",
	    "resource_description": {
	      "hasComponentID": "urn:publicid:IDN+samant+uxv+netmode1",
	      "hasSliceID": "urn:publicid:IDN+omf:netmode+account+__default__",
	      "resourceId": "UxV_NETMODE1",
	      "hasInterface": [
	        {
	          "name": "uav1:wlan0",
	          "type": "wireless_interface",
	          "authority": "samant",
	          "resource_description": {
	            "hasComponentID": "urn:publicid:IDN+samant+wireless_interface+uav1:wlan0",
	            "hasComponentName": "uav1:wlan0",
	            "hasRole": "experimental"
	          }
	        },
	        {
	          "name": "uav1:eth0",
	          "type": "wired_interface",
	          "authority": "samant",
	          "resource_description": {
	            "hasComponentID": "urn:publicid:IDN+samant+wired_interface+uav1:eth0",
	            "hasComponentName": "uav1:eth0",
	            "hasRole": "experimental"
	          }
	        }
	      ],
	      "hasUxVType": "http://www.semanticweb.org/rawfie/samant/omn-domain-uxv#UaV/"
	    }
	  }
	}

To populate the database with the resources:

	$ curl --cert user_cert.pem --key user_cert.pkey -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST-d @jsons/cr_uxv.json -k https://localhost:443/admin/create

Now let's use the REST interface again to see the data we created:

	$ curl --cert user_cert.pem --key user_cert.pkey -i -H "Accept: application/json" -H "Content-Type:application/json" -X GET d @jsons/get_inf.json -k https://localhost:443/admin/getinfo


Testing REST API
----------------

The most enriched way to interact with SAM is through its REST API. Start with listing all available resources:

   $ curl --cert certs_p12/root.p12:pass -i -H 'Accept: application/json' -H 'Content-Type:application/json' -X GET -d @jsons/LR_options.json -k https://localhost:443/samant/listresources

with LR_options.json containing

	{
	  "options": {
	    "only_available": true
	  }
	}

Please note the -k (or --insecure) option as we are using SSL but the server by default is not using a
cert signed by a public CA.


Using sfi.py
============


Get Version
-----------

    $ sfi.py version
	{   'geni_ad_rspec_versions': [   {   'extensions': [   'http://nitlab.inf.uth.gr/schema/sfa/rspec/1/ad-reservation.xsd'],
                                      'namespace': 'http://www.geni.net/resources/rspec/3',
                                      'schema': 'http://www.geni.net/resources/rspec/3/ad.xsd',
                                      'type': 'geni',
                                      'version': '3'}],
    'geni_api': 3,
    'geni_api_versions': {   '3': 'http://nitlab.inf.uth.gr:8001/RPC3'},
    'geni_credential_types': [{   'geni_type': 'geni_sfa', 'geni_version': 3}],
    'geni_request_rspec_versions': [   {   'extensions': [   'http://nitlab.inf.uth.gr/schema/sfa/rspec/1/request-reservation.xsd'],
                                           'namespace': 'http://www.geni.net/resources/rspec/3',
                                           'schema': 'http://www.geni.net/resources/rspec/3/request.xsd',
                                           'type': 'geni',
                                           'version': '3'}],
    'omf_am': '0.1'}

List Resources
--------------

    sfi.py resources
	<?xml version="1.0"?>
	<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ol="http://nitlab.inf.uth.gr/schema/sfa/rspec/1" xmlns:omf="http://schema.mytestbed.net/sfa/rspec/1" type="advertisement" xsi:schemaLocation="http://www.geni.net/resources/rspec/3 http://www.geni.net/resources/rspec/3/ad.xsd http://nitlab.inf.uth.gr/schema/sfa/rspec/1 http://nitlab.inf.uth.gr/schema/sfa/rspec/1/ad-reservation.xsd" generated="2017-06-27T12:20:27+03:00" expires="2017-06-27T12:30:27+03:00">
	  <ol:lease id="f4996b30-956c-4e46-a8c0-187707311c1b" client_id="l1" sliver_id="urn:publicid:IDN+omf:netmode+sliver+f4996b30-956c-4e46-a8c0-187707311c1b" valid_from="2010-01-08T19:00:00Z" valid_until="2017-11-08T20:00:00Z"/>
	  <node component_id="urn:publicid:IDN+omf:nitos.outdoor+node+node001" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node001" exclusive="true">
	    <available now="false"/>
	    <hardware_type name="PC-Grid"/>
	    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node001:if0" component_name="node001:if0" role="control">
	      <ip address="10.0.1.1" type="ipv4" netmask="255.255.255.0"/>
	    </interface>
	    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node001:if1" component_name="node001:if1" role="experimental"/>
	    <ol:lease_ref id_ref="f4996b30-956c-4e46-a8c0-187707311c1b"/>
	    <location latitude="39.360814" longitude="22.950075"/>
	    <sliver_type name="miniPC1">
	      <disk_image name="Voyage-0.9.2" os="Ubuntu" version="3.10.11-voyage"/>
	    </sliver_type>
	  </node>
	  <node component_id="urn:publicid:IDN+omf:nitos.outdoor+node+node001" component_manager_id="urn:publicid:IDN+omf:netmode+authority+cm" component_name="node0134" exclusive="true">
	    <available now="true"/>
	    <hardware_type name="PC-Grid"/>
	    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node001:if0" component_name="node001:if0" role="control">
	      <ip address="10.0.1.1" type="ipv4" netmask="255.255.255.0"/>
	    </interface>
	    <interface component_id="urn:publicid:IDN+omf:netmode+interface+node001:if1" component_name="node001:if1" role="experimental"/>
	    <location latitude="39.360814" longitude="22.950075"/>
	  </node>
	</rspec>


Debugging hints
===============

Use the following command to show the content of a cert in a human readable form:

    $ openssl x509 -in ~/.gcf/alice-cert.pem -text

To verify certificates, use openssl to set up a simple SSL server as well as
connect to it.

Server:

    % openssl s_server -cert ~/.gcf/am-cert.pem -key ~/.gcf/am-key.pem -verify on

Client:

    % openssl s_client -cert ~/.gcf/alice-cert.pem -key ~/.gcf/alice-key.pem
    % openssl s_client -connect 127.0.0.1:8001 -key ~/.gcf/alice-key.pem -cert ~/.gcf/alice-cert.pem -CAfile ~/.gcf/trusted_roots/CATedCACerts.pem
