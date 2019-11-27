# frozen_string_literal: true

module Simulator
  module Unit
    class FpAddUnit < Base
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
        @clock_cycles_required = state.configuration.fp_adder
        @clock_cycles_pending = state.configuration.fp_adder
        @pipelined = state.configuration.adder_pipelined
      end
    end
  end
end
