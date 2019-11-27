# frozen_string_literal: true

module Simulator
  module Unit
    class WriteBackUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        return if peek.nil?

        instruction = remove

        instruction.out_clock_cycles['WB'] = state.clock_cycle
        return unless instruction.result[:register_write]
        return unless instruction.result[:destination].start_with?('R')

        state.register_state.convert_to_binary_and_store(
          instruction.result[:destination],
          instruction.result[:value]
        )
        @clock_cycles_pending -= 1
      end

      def accept(instruction)
        return nil if busy?

        instruction.in_clock_cycles['WB'] = state.clock_cycle
        add(instruction)
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
