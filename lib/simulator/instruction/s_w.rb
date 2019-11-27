# frozen_string_literal: true

module Simulator
  module Instruction
    class SW
      attr_accessor :instruction, :register_state, :memory
      def initialize(instruction, register_state, memory)
        @instruction = instruction
        @register_state = register_state
        @memory = memory
      end

      def execute
        validate
        value = register_state.convert_to_int(instruction.operand_1)
        memory_location = instruction.operand_2.offset.to_i + register_state.convert_to_int(instruction.operand_2.register)
        # send to write back
        # memory.convert_to_binary_and_store(memory_location, value)
        instruction.result = { destination: memory_location, value: value, memory_write: true, register_write: false }
      end

      def validate
        true
      end
    end
  end
end
