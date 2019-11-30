# frozen_string_literal: true

module Simulator
  module Instruction
    class BNE
      attr_accessor :instruction, :state
      def initialize(instruction, state)
        @instruction = instruction
        @state = state
      end

      def execute
        value_1 = state.register_state.convert_to_int(instruction.operand_1.register)
        value_2 = state.register_state.convert_to_int(instruction.operand_2.register)
        value_1 != value_2
      end
    end
  end
end
