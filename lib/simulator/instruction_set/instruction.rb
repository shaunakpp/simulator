# frozen_string_literal: true

module Simulator
  class InstructionSet
    class Instruction
      attr_accessor :operation, :operand_1, :operand_2, :operand_3, :instruction_number
      attr_accessor :in_clock_cycles, :out_clock_cycles, :result
      def initialize(operation)
        @operation = operation
        @in_clock_cycles = {}
        @out_clock_cycles = {}
        @result = {}
      end

      def execution_class
        class_name = operation.gsub('.', '')
        Object.const_get("Simulator::Instruction::#{class_name}")
      end
    end
  end
end
