# frozen_string_literal: true

module Simulator
  module Unit
    class FetchUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        accept if peek.nil?
        instruction = peek
        return nil if instruction.nil?
        return nil if Stage::Decode.get(state).busy?

        remove
        instruction.out_clock_cycles['IF'] = state.clock_cycle
        @clock_cycles_pending -= 1
        instruction
      end

      def accept
        instruction = fetch_next
        return if instruction.nil?
      end

      def fetch_next
        return nil if busy?

        # TODO: implement cache
        instruction = state.instruction_set.fetch(state.program_counter)
        return nil if instruction.nil?

        add(instruction)
        instruction.in_clock_cycles['IF'] = state.clock_cycle
        @clock_cycles_pending = 1
        state.program_counter += 1
        instruction
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
