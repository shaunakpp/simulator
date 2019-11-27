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
        value = instruction.operand_2.offset.to_i + state.register_state.convert_to_int(instruction.operand_2.register)
        # memory[value]
        # binding.pry if memory[value].nil?
        # state.register_state.convert_to_binary_and_store(instruction.operand_1.register, memory[value])
        instruction.result = { destination: instruction.operand_1.register, value: state.memory.convert_to_int(value), memory_write: false, register_write: true }
      end

      def validate
        true
      end
    end
  end
end
