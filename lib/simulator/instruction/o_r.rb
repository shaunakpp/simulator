# frozen_string_literal: true

module Simulator
  module Instruction
    class OR
      attr_accessor :instruction, :state
      def initialize(instruction, state)
        @instruction = instruction
        @state = state
      end

      def execute
        value_1 = state.register_state.convert_to_int(@instruction.operand_2.register)
        value_2 = state.register_state.convert_to_int(@instruction.operand_3.register)
        value_3 = value_1 | value_2
        instruction.result = { destination: instruction.operand_1.register, value: value_3, register_write: true, memory_write: false }
      end
    end
  end
end
