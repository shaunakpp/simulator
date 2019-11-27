# frozen_string_literal: true

module Simulator
  module Stage
    class WriteBack
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state, :write_back_unit
      def initialize(state)
        @state = state
        @write_back_unit = Unit::WriteBackUnit.get(state)
      end

      def call
        write_back_unit.execute
      end

      def accept(instruction)
        write_back_unit.accept(instruction)
      end

      def busy?
        write_back_unit.busy?
      end
    end
  end
end
