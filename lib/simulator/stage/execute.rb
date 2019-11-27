# frozen_string_literal: true

module Simulator
  module Stage
    class Execute
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state
      def initialize(state)
        @state = state
        @functional_units = [
          Unit::IntegerUnit.get(state),
          # Unit::MemoryUnit.get(state),
          Unit::FpAddUnit.get(state),
          Unit::FpMultiplyUnit.get(state),
          Unit::FpDivideUnit.get(state)
        ]
        @contention_list = {}
      end

      def call
        execute
        send_to_write_back
      end

      def execute
        @functional_units.each do |unit|
          instruction = unit.execute
          next if instruction.nil?
        end
      end

      def accept(instruction)
        get_functional_unit(instruction).accept(instruction)
      end

      def mark_for_contention(functional_unit, instruction)
        @contention_list[functional_unit] = instruction
      end

      def send_to_write_back
        @contention_list.each do |functional_unit, instruction|
          instruction.out_clock_cycles['EX'] = state.clock_cycle
          write_back_stage = Stage::WriteBack.get(state)
          write_back_stage.accept(instruction)
        end
        @contention_list = {}
      end
      # rubocop:disable Metrics/LineLength
      def get_functional_unit(instruction)
        case instruction.operation
        when 'LW', 'SW', 'L.D', 'S.D', 'DADD', 'DADDI', 'AND', 'ANDI', 'OR', 'ORI', 'DSUB', 'DSUBI', 'J', 'BNE', 'BEQ'
          Unit::IntegerUnit.get(state)
        when 'ADD.D', 'SUB.D'
          Unit::FpAddUnit.get(state)
        when 'MUL.D'
          Unit::FpMultiplyUnit.get(state)
        when 'DIV.D'
          Unit::FpDivideUnit.get(state)
        else
          raise "Functional Unit not found for : #{instruction.operation}"
        end
      end
      # rubocop:enable Metrics/LineLength
    end
  end
end
