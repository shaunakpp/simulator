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

        return if Cache::ICache.get(state).busy?

        remove
        return nil if busy?

        instruction.out_clock_cycles['IF'] = state.clock_cycle
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

        if i_cache.busy?
          i_cache.burn_clock_cycle
          return nil
        end
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
