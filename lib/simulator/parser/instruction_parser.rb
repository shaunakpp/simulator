# frozen_string_literal: true

module Simulator
  module Parser
    MEMORY_REGEX = /(\d)\((R\d+)\)/i.freeze
    IMMEDIATE_REGEX = /(\d+)/i.freeze
    INT_REGISTER_REGEX = /(R\d+)/i.freeze
    FP_REGISTER_REGEX = /(F\d+)/i.freeze
    LOOP_NAME_REGEX = /([A-Z]+\:)/i.freeze
    class InstructionParser
      attr_reader :file
      attr_accessor :loop_name, :instruction_set

      def self.parse(file)
        obj = new(file)
        obj.parse
        obj
      end

      def initialize(file)
        @file = file
        @instruction_set = InstructionSet.new
      end

      def parse
        File.readlines(file).each_with_index do |line, index|
          inst = parse_instruction(line, index)
          inst.instruction_number = index
          instruction_set.instructions << inst
        end
      end

      def parse_instruction(line, index)
        if line.match?(LOOP_NAME_REGEX)
          loop_name = line.match(LOOP_NAME_REGEX).captures.first
          line.gsub!(LOOP_NAME_REGEX, '')
          instruction_set.labels[loop_name.gsub(':', '')] = index
        end
        line.gsub!(',', '')
        operation, *operands = line.split(' ')

        inst = InstructionSet::Instruction.new(operation)
        fill_operands(inst, operands)
        inst
      end

      # rubocop:disable Metrics/LineLength
      # rubocop:disable Metrics/MethodLength
      def fill_operands(inst, operands)
        operands.each_with_index do |operand, index|
          case operand
          when MEMORY_REGEX
            offset, register = operand.match(MEMORY_REGEX).captures
            inst.send("operand_#{index + 1}=", Operand::Memory.new(offset, register))
          when INT_REGISTER_REGEX
            register = operand.match(INT_REGISTER_REGEX).captures.first
            inst.send("operand_#{index + 1}=", Operand::Register.new(register))
          when FP_REGISTER_REGEX
            register = operand.match(FP_REGISTER_REGEX).captures.first
            inst.send("operand_#{index + 1}=", Operand::Register.new(register))
          when IMMEDIATE_REGEX
            value = operand.match(IMMEDIATE_REGEX).captures.first
            inst.send("operand_#{index + 1}=", Operand::Immediate.new(value))
          when *instruction_set.labels.keys
            inst.send("operand_#{index + 1}=", Operand::Label.new(operand))
          else
            raise "Operand not parsed for: #{operand}"
          end
        end
        inst
        # rubocop:enable Metrics/LineLength
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
