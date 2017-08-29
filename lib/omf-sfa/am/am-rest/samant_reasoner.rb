require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'
require 'omf-sfa/am/am_manager'
require 'uuid'
require_relative '../../omn-models/resource.rb'
require_relative '../../omn-models/populator.rb'
require 'pathname'

module OMF::SFA::AM::Rest

  class SamantReasoner < RestHandler

    def find_handler(path, opts)
      debug "!!!SAMANT reasoner!!!"
      RDF::Util::Logger.logger.parent.level = 'off' # Worst Bug *EVER*
      # debug "PATH = " + path.inspect
      # Define method called
      if path.map(&:downcase).include? "uxv-endurance"
        opts[:resource_uri] = :endurance
      elsif path.map(&:downcase).include? "uxv-distance"
        opts[:resource_uri] = :distance
      elsif path.map(&:downcase).include? "uxv"
        opts[:resource_uri] = :uxv
      else
        raise OMF::SFA::AM::Rest::BadRequestException.new "Invalid URL."
      end
      return self
    end

    # GET:
    #
    # @param method used to select which functionality is selected
    # @param [Hash] options of the request
    # @return [String] Description of the requested resource.

    def on_get (method, options)
      if method == :endurance
        endurance(options)
      elsif method == :distance
        distance(options)
      elsif method == :uxv
        uxv(options)
      end
    end

    def endurance(options)
      path = options[:req].env["REQUEST_PATH"]

      # Transform path to resources

      path_ary = Pathname(path).each_filename.to_a
      # ODO consider changing :resourceId to :hasID *generally*
      uxv = @am_manager.find_all_samant_resources(["Uxv"], {resourceId: path_ary[path_ary.index{|item| item.downcase == "uxv-endurance"} + 1]})
      speed = path_ary[path_ary.index{|item| item.downcase == "speed"} + 1].to_i
      sensor_ary = path_ary[(path_ary.index{|item| item.downcase == "sensor"} + 1)]
                           .split(",")
                           .map {|sensorId| @am_manager.find_all_samant_resources(["System"], {hasID: sensorId})}
                           .flatten unless !path_ary.index{|item| item.downcase == "sensor"}
      sensor_ary = [] if sensor_ary == nil
      netIfc_ary = path_ary[(path_ary.index{|item| item.downcase == "netifc"} + 1)]
                        .split(",")
                        .map {|netifcId| @am_manager.find_all_samant_resources(["WiredInterface"], {hasComponentName: netifcId}) + @am_manager.find_all_samant_resources(["WirelessInterface"], {hasComponentName: netifcId})}
                        .flatten unless !path_ary.index{|item| item.downcase == "netifc"}
      netIfc_ary = [] if netIfc_ary == nil

      # debug uxv.inspect + " " + speed.to_s + " " + sensor_ary.inspect + " " + netIfc_ary.inspect

      # Validate if uxv actually exists

      if uxv.empty?
        @return_struct[:code][:geni_code] = 7 # operation refused
        @return_struct[:output] = "UxV doesn't exist. Please use the List Resources call to check the available resources."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      else
        uxv = uxv.first
      end

      # Validate if sensors and interfaces actually exist in given uxv

      unless (sensor_ary - uxv.hasSensorSystem.hasSubSystem).empty? && (netIfc_ary.map{|ifc| ifc.uri} - uxv.hasInterface.map{|ifc| ifc.uri}).empty?
        @return_struct[:code][:geni_code] = 7 # operation refused
        @return_struct[:output] = "Some or all of the given Sensors or Network Interfaces are not compatible with the given UxV. Please use the List Resources call to check the compatibility again."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      # Compute the total time duration (in seconds) of a specific node travelling with the specified average speed / sensors / network interfaces, using the given model

      # TODO come up with an appropriate consumption model
      # endurance = uxv.hasConsumption*speed + ...

      @return_struct[:code][:geni_code] = 0
      #@return_struct[:value] = endurance
      @return_struct[:value] = ''
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]

    end

    def distance(options)
      path = options[:req].env["REQUEST_PATH"]

      # Transform path to resources

      path_ary = Pathname(path).each_filename.to_a
      # TODO consider changing :resourceId to :hasID *generally*
      uxv = @am_manager.find_all_samant_resources(["Uxv"], {resourceId: path_ary[path_ary.index{|item| item.downcase == "uxv-distance"} + 1]})
      speed = path_ary[path_ary.index{|item| item.downcase == "speed"} + 1].to_i

      # Validate if uxv actually exists

      if uxv.empty?
        @return_struct[:code][:geni_code] = 7 # operation refused
        @return_struct[:output] = "UxV doesn't exist. Please use the List Resources call to check the available resources."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      else
        uxv = uxv.first
      end

      # Compute the total distance (in meters) that a specified node can cover, having the given average speed, using the given model and based on the node's battery life

      # TODO come up with an appropriate distance computation model
      # distance = ...

      @return_struct[:code][:geni_code] = 0
      #@return_struct[:value] = distance
      @return_struct[:value] = ''
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]

    end

    def uxv(options)
      path = options[:req].env["REQUEST_PATH"]

      # Transform path to resources

      path_ary = Pathname(path).each_filename.to_a
      # TODO consider changing :resourceId to :hasID *generally*
      uxv = @am_manager.find_all_samant_resources(["Uxv"], {resourceId: path_ary[path_ary.index{|item| item.downcase == "uxv"} + 1]}).first
      if path_ary.index{|item| item.downcase == "sensor"}
        res = uxv.hasSensorSystem.hasSubSystem.map{|sensor| sensor.observes}
      elsif path_ary.index{|item| item.downcase == "sensorType"}
        sensorType = path_ary[path_ary.index{|item| item.downcase == "sensorType"} + 1]
        res = uxv.hasSensorSystem.hasSubSystem.type.include? sensorType
      elsif path_ary.index{|item| item.downcase == "netifc"}
        res = uxv.hasInterface.map{|ifc| ifc.hasComponentName}
      elsif path_ary.index{|item| item.downcase == "netifcType"}
        netifcType = path_ary[path_ary.index{|item| item.downcase == "netifcType"} + 1]
        res = uxv.hasInterface.include? netifcType
      else
        @return_struct[:code][:geni_code] = 7 # operation refused
        @return_struct[:output] = "Unknown operation requested. Please try again."
        @return_struct[:value] = ''
        return ['application/json', JSON.pretty_generate(@return_struct)]
      end

      @return_struct[:code][:geni_code] = 0
      @return_struct[:value] = res
      @return_struct[:output] = ''
      return ['application/json', JSON.pretty_generate(@return_struct)]

    end

  end
end