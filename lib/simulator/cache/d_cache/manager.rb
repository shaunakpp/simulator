# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      class Manager
        def self.get(state)
          @get ||= new(state)
        end
        attr_accessor :state, :cache, :request, :cache_requests, :cache_hits
        attr_accessor :cache_access_time, :memory_access_time

        def initialize(state)
          @state = state
          @cache = DCache.new
          @request = DCache::Request.new
          @cache_requests = 0
          @cache_hits = 0
          @cache_access_time = state.configuration.d_cache
          @memory_access_time = state.configuration.memory
        end

        def fetch(instruction)
          address = instruction.result[:value]
          if request.instruction.nil?

            request.instruction = instruction
            request.double = true if %w[L.D S.D].include?(instruction.operation)
            request.clock_cycle = state.clock_cycle
            update_clock_cycles_for_address(address)
          else
            update_stats_for_address(address) unless request.stats_updated
          end

          cache.update(address, %w[S.D SW].include?(instruction.operation))

          if request.double
            if request.double_instruction_pending
              update_clock_cycles_for_address(address + 4)
              request.double_instruction_pending = false
            elsif request.double_stats_pending
              update_stats_for_address(address + 4)
              request.double_stats_pending = false
            end
            cache.update(address + 4, %w[S.D SW].include?(instruction.operation))
          end
        end

        def update_stats_for_address(address)
          @cache_requests += 1
          request.stats_updated = true
          @cache_hits += 1 if request.hit[address]
        end

        def update_clock_cycles_for_address(address)
          if %w[S.D SW].include?(request.instruction.operation)
            update_clock_cycles_for_store(address)
          else
            update_clock_cycles_for_load(address)
          end
        end

        def update_clock_cycles_for_store(address)
          if cache.address_present?(address)
            request.hit[address] = true
            return request.clock_cycles_to_burn += cache_access_time
          end

          if cache.blocks_available?(address) || cache.lru_dirty?
            return request.clock_cycles_to_burn += cache_miss_penalty + cache_access_time
          end

          request.hit[address] = true
          request.clock_cycles_to_burn += 2 * cache_access_time
        end

        def update_clock_cycles_for_load(address)
          if cache.address_present?(address)
            request.hit[address] = true
            return request.clock_cycles_to_burn += cache_access_time
          end

          if cache.blocks_available?(address) || cache.lru_dirty?(address)
            return request.clock_cycles_to_burn += cache_miss_penalty
          end

          request.hit[address] = true
          request.clock_cycles_to_burn += cache_access_time
        end

        def clock_cycles_to_burn
          request.clock_cycles_to_burn
        end

        def check!
          request.reset if clock_cycles_burned?
          clock_cycles_burned?
        end

        def clock_cycles_burned?
          return true if request.clock_cycle.nil?

          state.clock_cycle - request.clock_cycle + 1 == clock_cycles_to_burn
        end

        def cache_miss_penalty
          2 * (cache_access_time + memory_access_time)
        end

        def cache_stats
          {
            requests: @cache_requests,
            hits: @cache_hits
          }
        end
      end
    end
  end
end
