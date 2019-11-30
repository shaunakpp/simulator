# frozen_string_literal: true

module Simulator
  module Stage
    class Decode
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state, :decode_unit
      def initialize(state)
        @state = state
        @decode_unit = Unit::DecodeUnit.get(state)
      end

      def call
        # TODO: check registers busy or not
        instruction = decode_unit.execute
        return if instruction.nil?
        return if branch?(instruction)

        execute_stage = Execute.get(state)
        execute_stage.accept(instruction)
      end

      def accept(instruction)
        decode_unit.accept(instruction)
      end

      def branch?(instruction)
        decode_unit.branch?(instruction)
      end

      def busy?
        decode_unit.busy?
      end
    end
  end
end
