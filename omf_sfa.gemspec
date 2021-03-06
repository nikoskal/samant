# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omf-sfa/version"

Gem::Specification.new do |s|
  s.name        = "omf_sfa"
  s.version     = OMF::SFA::VERSION
  s.authors     = ["NICTA"]
  s.email       = ["omf-user@lists.nicta.com.au"]
  s.homepage    = "https://www.mytestbed.net"
  s.summary     = %q{OMF's SFA compliant AM.}
  s.description = %q{OMF's Aggregate manager with SFA and new REST API.}

  s.rubyforge_project = "omf_sfa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "json-ld"
  s.add_runtime_dependency "rake", "11.2.2"
  s.add_runtime_dependency "rdf", "2.0.0"
  s.add_development_dependency "minitest", "5.1" # was 4.3.3
  s.add_runtime_dependency "nokogiri", "1.5.6"
  s.add_runtime_dependency "erector", "0.8.3"
  s.add_runtime_dependency "rack", "1.5.2"
  s.add_runtime_dependency "thin", "1.6.0"
  s.add_runtime_dependency "daemons", "1.0.9"
  s.add_runtime_dependency "log4r", "1.1.10"
  s.add_runtime_dependency "maruku", "0.6.0"
  s.add_runtime_dependency "uuid", "2.3.5"
  s.add_runtime_dependency "json", "1.7.7"
  s.add_runtime_dependency "blather", "1.0.0"
  s.add_runtime_dependency "spira", "2.0.0"
  s.add_runtime_dependency "rdf-turtle", "2.0.0"
  s.add_runtime_dependency "rdf-json", "2.0.0"
  s.add_runtime_dependency "sparql", "2.0.0"
  s.add_runtime_dependency "sparql-client"
  s.add_runtime_dependency "rdf-vocab", "2.0.2"
  s.add_runtime_dependency "builder", "3.2"
  s.add_runtime_dependency "rdf-do", "2.0.0"
  s.add_runtime_dependency "do_sqlite3"
  s.add_runtime_dependency "rdf-sesame"
  #s.add_runtime_dependency "do_postgres"
#
  s.add_runtime_dependency "equivalent-xml", "0.2.9"
  s.add_runtime_dependency "rspec", "2.11.0"
  s.add_runtime_dependency "activesupport", "4.2.6" # was 3.2.8
  s.add_runtime_dependency "rack-rpc" # "~> 0.0.12"
  s.add_runtime_dependency "data_mapper", "1.2.0"
  s.add_runtime_dependency "bluecloth", "2.2.0"
  s.add_runtime_dependency "omf_common", "6.1.12"
  s.add_runtime_dependency "omf_rc", "6.1.12"
  s.add_runtime_dependency "eventmachine", "1.0.3"
  s.add_runtime_dependency "em-minitest-spec", "1.1.1"
  s.add_runtime_dependency "sequel", "4.17.0"
  s.add_runtime_dependency "rufus-scheduler", "3.0.9"
  s.add_runtime_dependency "sqlite3", "1.3.10"
end
