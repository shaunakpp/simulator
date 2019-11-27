# frozen_string_literal: true

module Simulator
  module Unit
    class DecodeUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        # TODO: handle branching
        # TODO: process hazards
        return if peek.nil?

        instruction = peek
        instruction.in_clock_cycles['ID'] = state.clock_cycle
        @clock_cycles_pending -= 1
        execute_stage = Stage::Execute.get(state)
        unless execute_stage.get_functional_unit(instruction).busy?
          remove
          instruction.out_clock_cycles['ID'] = state.clock_cycle
        end
        instruction
      end

      def accept(instruction)
        return nil if busy?

        @clock_cycles_pending = 1
        add(instruction)
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
