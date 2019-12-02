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
        instruction.out_clock_cycles['IF'] = state.clock_cycle
        return nil if Stage::Decode.get(state).busy?

        remove

        state.program_counter += 1
        instruction
      end

      def accept
        return nil if busy?

        instruction = fetch_next
        return if instruction.nil?
      end

      def fetch_next
        i_cache = Cache::ICache.get(state)
        i_cache.burn_clock_cycle if i_cache.busy?

        instruction = i_cache.fetch(state.program_counter)

        return if instruction.nil?

        add(instruction)
        instruction.in_clock_cycles['IF'] = state.clock_cycle
        instruction
      end

      def parse_config
        @clock_cycles_required = Cache::ICache.get(state).cache_time_required
        @clock_cycles_pending = state.configuration.i_cache
      end
    end
  end
end
