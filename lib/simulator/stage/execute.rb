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
          Unit::IntegerUnit.get(state)
        ]
      end

      def call
        execute
        return if busy?
        return if @functional_unit.nil?

        instruction = @functional_unit.peek
        write_back_stage = Stage::WriteBack.get(state)
        return if write_back_stage.busy? || instruction.nil?

        write_back_stage.accept(instruction)
      end

      def execute
        @functional_units.each(&:execute)
      end

      def accept(instruction)
        @functional_unit = get_functional_unit(instruction)
        return nil if busy?

        @functional_unit.accept(instruction)
      end

      def busy?
        return true if @functional_unit.nil?

        @functional_unit.busy?
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
