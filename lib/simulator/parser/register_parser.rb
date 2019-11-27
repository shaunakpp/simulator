# frozen_string_literal: true

load 'lib/simulator/register_state.rb'
module Simulator
  module Parser
    class RegisterParser
      attr_accessor :file, :register_state
      def initialize(file)
        @file = file
        @register_state = RegisterState.new
      end

      def self.parse(file)
        obj = new(file)
        obj.parse
        obj
      end

      def parse
        File.readlines(file).each_with_index do |line, index|
          register_state["R#{index}"] = line.chomp
        end
        register_state
      end
    end
  end
end
