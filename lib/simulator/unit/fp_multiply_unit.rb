# frozen_string_literal: true

module Simulator
  module Unit
    class FpMultiplyUnit
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        @current_instruction = instruction
      end

      def execute
        {}
      end

      def busy?
        @clock_cycles_pending.to_i.positive?
      end

      def parse_config
        @clock_cycles_required = state.configuration.fp_multiplier
        @clock_cycles_pending = state.configuration.fp_multiplier
        @pipelined = state.configuration.multiplier_pipelined
      end
    end
  end
end
