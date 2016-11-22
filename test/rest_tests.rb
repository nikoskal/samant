require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
# require 'net/http'
 require 'rest-client'
require 'json'

class RestTests < Minitest::Unit::TestCase


  @@random_number = Random.rand(1100)
  def setup
    puts "start testing Broker at localhost:8001 "
    puts "setting up"
    puts "test_create_node"

    json_payload = '{"name":"Ioannina%{number}","x":11.11111,"y":22.2222}' % { number:@@random_number }
    puts json_payload
    result = RestClient::Request.execute(method: :post, url: 'https://localhost:8001/omn-resources/locations',
                                         headers: {content_type: "application/json" , accept: "application/json"},
                                         payload: json_payload,
                                         :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read("user_cert.pem")),
                                         :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read("user_cert.pkey")),
                                         :verify_ssl       =>  OpenSSL::SSL::VERIFY_NONE)

    # puts result
    puts "test_create_node end";

    case result.code
      when 200
        assert(true)
        result
      else
        assert(false)
    end

  end




  def test_get_location_resource
    puts "test_get_location_resource"
    json_payload = '{"name":"Ioannina%{number}"}'% { number:@@random_number }

    # json_payload = '{"name":"Ioannina1234567"}'% { number:@@random_number }
    puts json_payload


    result = RestClient::Request.execute(method: :get, url: 'https://localhost:8001/omn-resources/locations',
                                           headers: {content_type: "application/json" , accept: "application/json"},
                                           payload: json_payload,
                                           :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read("user_cert.pem")),
                                           :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read("user_cert.pkey")),
                                           :verify_ssl       =>  OpenSSL::SSL::VERIFY_NONE)

    puts  result
    puts  result.code

    case result.code
      when 200
        assert(true)
      else
        assert(false)
    end

  end


  # def test_get_resources
  #   puts "test_get_resources"
  #
  #   resource = RestClient::Resource.new(
  #       'https://localhost:8001/omn-resources/nodes',
  #       :verify_ssl       =>  OpenSSL::SSL::VERIFY_NONE
  #   )
  #   response = resource.get
  #
  #   puts "response code"
  #   puts response.code
  #   json_res = JSON.parse(response)
  #
  #   puts json_res.is_a?(Array)
  #
  #
  #   puts "json to array"
  #   puts json_res # => {"val"=>"test","val1"=>"test1","val2"=>"test2"}
  #   puts "access array"
  #   puts json_res.length
  #   puts json_res[0].is_a?(Hash)
  #
  #   hash_item = json_res[0]
  #
  #   puts "print keys"
  #   puts hash_item.keys
  #   first_item =  hash_item["http://open-multinet.info/ontology/omn-resource#Node/node2"]
  #   puts first_item.is_a?(Hash)
  #   puts first_item
  #
  #   # puts json_res["http://open-multinet.info/ontology/omn-resource#Node/node2"].to_s
  #   assert_equal 200, response.code
  # end



  def teardown
    puts "tearing down"

    json_payload = '{"name":"Ioannina%{number}"}'% { number:@@random_number }
    puts json_payload
    result = RestClient::Request.execute(method: :delete, url: 'https://localhost:8001/omn-resources/locations',
                                         headers: {content_type: "application/json" , accept: "application/json"},
                                         payload: json_payload,
                                         :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read("user_cert.pem")),
                                         :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read("user_cert.pkey")),
                                         :verify_ssl       =>  OpenSSL::SSL::VERIFY_NONE)

    puts result
    case result.code
      when 200
        assert(true)
      else
        assert(false)
    end
    puts "test_delete_node end"
  end


end