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

      def prioritize_contention_units
        units = @contention_list.values.uniq
        # get non-pipelined first and then descending order of clock cycles
        units.partition { |unit| unit.pipelined == false }.flatten.sort_by { |unit| -unit.clock_cycles_required }
      end

      def prioritize_instructions
        units = prioritize_contention_units
        instructions = @contention_list.select { |_k, v| units.include?(v) }.keys
        instructions.sort_by! { |instruction| instruction.in_clock_cycles['EX'] }
        instructions
      end

      def mark_for_contention(functional_unit, instruction)
        @contention_list[instruction] = functional_unit
      end

      def send_to_write_back
        return if @contention_list.empty?

        instruction = if @contention_list.keys.count == 1
                        @contention_list.keys.first
                      else
                        prioritize_instructions.first
                      end
        instruction.out_clock_cycles['EX'] = state.clock_cycle
        @contention_list.delete(instruction)
        write_back_stage = Stage::WriteBack.get(state)
        write_back_stage.accept(instruction)
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
