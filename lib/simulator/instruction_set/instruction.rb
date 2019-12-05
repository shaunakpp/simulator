# frozen_string_literal: true

module Simulator
  class InstructionSet
    class Instruction
      attr_accessor :operation, :operand_1, :operand_2, :operand_3,
                    :instruction_number, :label
      attr_accessor :in_clock_cycles, :out_clock_cycles, :result, :hazards
      def initialize(operation)
        @operation = operation
        @in_clock_cycles = { 'IF' => nil, 'ID' => nil, 'EX' => nil, 'WB' => nil }
        @out_clock_cycles = { 'IF' => nil, 'ID' => nil, 'EX' => nil, 'WB' => nil }
        @result = {}
        @hazards = { 'RAW' => 'N', 'WAW' => 'N', 'WAR' => 'N', 'Struct' => 'N' }
        @label
      end

      def execution_class
        class_name = operation.gsub('.', '')
        Object.const_get("Simulator::Instruction::#{class_name}")
      end

      def to_s
        str = if label.nil?
                operation
              else
                label + operation
              end

        unless operand_1.nil?
          str += ' '
          str += operand_1.to_s
        end
        unless operand_2.nil?
          str += ', '
          str += operand_2.to_s
        end
        unless operand_3.nil?
          str += ', '
          str += operand_3.to_s
        end
        str
      end

      def stage_sequence
        [
          out_clock_cycles['IF'].to_s,
          out_clock_cycles['ID'].to_s,
          out_clock_cycles['EX'].to_s,
          out_clock_cycles['WB'].to_s
        ]
      end

      def hazards_sequence
        [hazards['RAW'], hazards['WAR'], hazards['WAW'], hazards['Struct']]
      end
    end
  end
end
