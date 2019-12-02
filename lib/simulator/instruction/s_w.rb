# frozen_string_literal: true

module Simulator
  module Instruction
    class SW
      attr_accessor :instruction, :state
      def initialize(instruction, state)
        @instruction = instruction
        @state = state
      end

      def execute
        validate
        value = instruction.operand_2.offset.to_i + state.register_state.convert_to_int(instruction.operand_2.register)
        memory_location = instruction.operand_2.offset.to_i + register_state.convert_to_int(instruction.operand_2.register)
        instruction.result = { destination: memory_location, value: value, memory_write: true, register_write: false }
      end

      def validate
        true
      end
    end
  end
end
