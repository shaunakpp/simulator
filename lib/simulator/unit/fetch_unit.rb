# frozen_string_literal: true

module Simulator
  module Unit
    class FetchUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        return accept if peek.nil?
        return nil if Stage::Decode.get(state).busy?

        @clock_cycles_pending -= 1
        instruction = remove
        instruction.out_clock_cycles['IF'] = state.clock_cycle
        instruction
      end

      def accept
        instruction = fetch_next
        return if instruction.nil?

        instruction.in_clock_cycles['IF'] = state.clock_cycle
        nil
      end

      def fetch_next
        return nil if busy?

        # TODO: implement cache
        instruction = state.instruction_set.fetch(state.program_counter)
        unless instruction.nil?
          add(instruction)
          @clock_cycles_pending = 1
          state.program_counter += 1
        end
        instruction
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
