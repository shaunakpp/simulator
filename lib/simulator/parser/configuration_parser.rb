# frozen_string_literal: true

module Simulator
  module Parser
    class InvalidConfigurationError < StandardError; end
    UNITS = ['fp adder', 'fp multiplier', 'fp divider'].freeze
    CACHE_AND_MEMORY = ['main memory', 'i-cache', 'd-cache'].freeze
    class ConfigurationParser
      attr_accessor :file, :configuration
      def initialize(file)
        @file = file
        @configuration = Configuration.new
      end

      def self.parse(file)
        obj = new(file)
        obj.parse
        obj
      end

      def parse
        File.readlines(file).each do |line|
          name, values = line.chomp.split(':')
          latency, pipelined = values.split(',')
          if pipelined.is_a?(String)
            pipelined.gsub!(' ', '')
            pipelined.downcase!
          end
          validate(name.downcase, latency, pipelined)
          case name.downcase
          when 'fp adder'
            configuration.fp_adder = latency.to_i
            configuration.adder_pipelined = pipelined == 'yes'
          when 'fp multiplier'
            configuration.fp_multiplier = latency.to_i
            configuration.multiplier_pipelined = pipelined == 'yes'
          when 'fp divider'
            configuration.fp_divider = latency.to_i
            configuration.divider_pipelined = pipelined == 'yes'
          when 'main memory'
            configuration.memory = latency.to_i
          when 'i-cache'
            configuration.i_cache = latency.to_i
          when 'd-cache'
            configuration.d_cache = latency.to_i
          end
        end
        configuration
      end

      def validate(name, latency, pipelined)
        if latency.to_i.zero?
          raise InvalidConfigurationError, "Latency not given for #{name}"
        end
        if latency.to_i.negative?
          raise InvalidConfigurationError, "Latency value incorrect for #{name}, provide a positive integer or zero"
        end

        return unless UNITS.include?(name.downcase)

        if pipelined.nil? || pipelined&.empty?
          raise InvalidConfigurationError, "Pipeline information not provided for #{name}"
        end

        if pipelined != 'no' && pipelined != 'yes'
          raise InvalidConfigurationError, "Pipeline information incorrect for #{name}, please provide yes/no"
        end
      end
    end
  end
end
