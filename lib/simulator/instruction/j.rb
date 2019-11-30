# frozen_string_literal: true

module Simulator
  module Instruction
    class J
      attr_accessor :instruction, :state
      def initialize(instruction, _state)
        @instruction = instruction
      end

      def execute
        label = instruction.operand_1.label
        instruction_set.labels[label]
      end
    end
  end
end
