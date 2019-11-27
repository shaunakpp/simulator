# frozen_string_literal: true

module Simulator
  module Parser
    class DataParser
      attr_accessor :file, :memory
      def initialize(file)
        @file = file
        @memory = Memory.new
      end

      def self.parse(file)
        obj = new(file)
        obj.parse
        obj
      end

      def parse
        File.readlines(file).each_with_index do |line, index|
          memory[0x100 + index] = line.chomp
        end
        memory
      end
    end
  end
end
