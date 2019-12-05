# frozen_string_literal: true

module Simulator
  module Instruction
    class LW
      attr_accessor :instruction, :state
      def initialize(instruction, state)
        @instruction = instruction
        @state = state
      end

      def execute
        validate
        address = instruction.operand_2.offset.to_i + state.register_state.convert_to_int(instruction.operand_2.register)
        value = state.memory.convert_to_int(value)
        instruction.result = {
          destination: instruction.operand_1.register,
          address: address,
          value: value,
          memory_write: false,
          register_write: true
        }
      end

      def validate
        true
      end
    end
  end
end
