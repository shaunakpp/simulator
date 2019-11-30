# frozen_string_literal: true

module Simulator
  module Cache
    class ICache
      def self.get(state)
        @get ||= new(state)
      end
      attr_accessor :state, :blocks, :cache_access_time, :memory_access_time
      attr_accessor :cache_requests, :cache_hits, :clock_cycles_to_burn

      def initialize(state)
        @state = state
        @blocks = []
        4.times do
          @blocks << [nil] * 4
        end
        @cache_access_time = state.configuration.i_cache
        @memory_access_time = state.configuration.memory
        @cache_requests = 0
        @cache_hits = 0
        @clock_cycles_to_burn = nil
      end

      def hit?(program_counter)
        blocks.flatten.include?(program_counter)
      end

      def fetch(program_counter)
        return nil if busy?

        if hit?(program_counter)
          @cache_requests += 1
          @cache_hits += 1
        else
          @cache_requests += 1
          index = find_free_block_index
          instructions = find_next_set_of_instructions(program_counter)
          4.times do |i|
            blocks[index][i] = instructions[i]
          end
        end
        state.instruction_set.fetch(program_counter)
      end

      def clock_cycles_required
        if hit?(state.program_counter)
          cache_access_time
        else
          cache_time_required
        end
      end

      def cache_time_required
        2 * (cache_access_time + memory_access_time)
      end

      def find_free_block_index
        @blocks.each_with_index do |block, index|
          return(index) if block.include?(nil)
        end
      end

      def busy?
        if @clock_cycles_to_burn.nil?
          @clock_cycles_to_burn = clock_cycles_required - 1
          return true
        end
        @clock_cycles_to_burn > 0
      end

      def burn_clock_cycle
        @clock_cycles_to_burn -= 1
      end

      def find_next_set_of_instructions(program_counter)
        (0...4).to_a.map do |i|
          state.instruction_set.fetch(program_counter + i)&.instruction_number
        end
      end
    end
  end
end
