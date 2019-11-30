# frozen_string_literal: true

module Simulator
  module Instruction
    class BEQ
      attr_accessor :instruction
      def initialize(instruction)
        @instruction = instruction
      end

      def execute
        value_1 = state.register_state.convert_to_int(instruction.operand_1)
        value_2 = state.register_state.convert_to_int(instruction.operand_2)
        value_1 == value_2
      end
    end
  end
end
