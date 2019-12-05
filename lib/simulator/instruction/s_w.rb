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
        address = instruction.operand_2.offset.to_i + state.register_state.convert_to_int(instruction.operand_2.register)
        memory_location = instruction.operand_2.offset.to_i + register_state.convert_to_int(instruction.operand_2.register)
        value = state.memory.convert_to_int(value)
        instruction.result = { destination: memory_location, address: address, value: value, memory_write: true, register_write: false }
      end

      def validate
        true
      end
    end
  end
end
