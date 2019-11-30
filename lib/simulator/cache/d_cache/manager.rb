module Simulator
  module Cache
    class DCache
      class Manager

        def self.get(state)
          @get ||= new(state)
        end
        attr_accessor :state, :cache, :request, :cache_requests, :cache_hits

        def initialize(state)
          @state = state
          @cache = DCache.new
          @request = DCache::Request.new
          @cache_requests = 0
          @cache_hits = 0
        end

        def fetch(instruction)
          address = instruction.result[:value]
          if request.instruction.nil?

            request.instruction = instruction
            request.clock_cycle = state.clock_cycle

            if %W[S.D SW].include?(instruction.operation)

              if cache.address_present?(address)
                request.clock_cycles_to_burn += state.configuration.d_cache
              else
                if cache.blocks_available?(address)
                  request.clock_cycles_to_burn += state.configuration.d_cache
                else
                  if cache.lru_dirty?(address)
                    request.clock_cycles_to_burn += 2 * (state.configuration.memory + state.configuration.d_cache)
                  else
                    request.clock_cycles_to_burn += state.configuration.d_cache
                  end
                end
              end
            else
              if cache.address_present?(address)
                request.clock_cycles_to_burn += state.configuration.d_cache
              else
                if cache.blocks_available?(address)
                  request.clock_cycles_to_burn += 2 * (state.configuration.memory + state.configuration.d_cache)
                else
                  if cache.lru_dirty?(address)
                    request.clock_cycles_to_burn += 2 * (state.configuration.memory + state.configuration.d_cache)
                  else
                    request.clock_cycles_to_burn += state.configuration.d_cache
                  end
                end
              end
            end
          else
            unless request.stats_updated
              @cache_requests += 1
              if cache.address_present?(address)
                @cache_hits += 1
              end
              request.stats_updated
            end

            binding.pry if address == false
            cache.update(address, %W[S.D SW].include?(instruction.operation))
          end
        end

        def clock_cycles_to_burn
          request.clock_cycles_to_burn
        end

        def clock_cycles_burned?
          if state.clock_cycle - request.clock_cycle == request.clock_cycles_to_burn
            request.reset
            true
          else
            false
          end
        end
      end
    end
  end
end
