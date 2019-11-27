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

        @clock_cycles_pending -= 1
        instruction = remove
        return if instruction.nil?

        instruction.out_clock_cycles['ID'] = state.clock_cycle
        instruction
      end

      def accept(instruction)
        return nil if busy?

        instruction.in_clock_cycles['ID'] = state.clock_cycle
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
