# frozen_string_literal: true

module Simulator
  module Unit
    class MemoryUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?(instruction)

        if memory_required?(instruction)
          cache = Cache::DCache::Manager.get(state)
          @clock_cycles_pending = cache.clock_cycles_to_burn
        else
          @clock_cycles_pending = 1
        end
        # instruction.in_clock_cycles['MEM'] = state.clock_cycle
        add(instruction)
      end

      def busy?(instruction = nil)
        return super() if instruction.nil?

        unit_busy = super()
        if !unit_busy && memory_required?(instruction)
          cache = Cache::DCache::Manager.get(state)
          return !cache.clock_cycles_burned?
        else
          super()
        end
      end

      def execute
        return if peek.nil?

        instruction = peek

        if memory_required?(instruction)
          cache = Cache::DCache::Manager.get(state)
          cache.fetch(instruction)
          @clock_cycles_pending = cache.clock_cycles_to_burn
          if  cache.clock_cycles_to_burn > state.configuration.d_cache
            cache.request.clock_cycles_to_burn += 1 if state.memory.busy?
          end
          if cache.check!
            if instruction.result[:memory_write]
              state.memory.convert_to_binary_and_store(
                instruction.result[:destination],
                instruction.result[:value]
              )
            end
            remove
            Stage::Execute.get(state).mark_for_contention(self, instruction)
            return instruction
          end
          return nil
        else
          @clock_cycles_pending -= 1

          unless @clock_cycles_pending.positive?
            # instruction.out_clock_cycles['MEM'] = state.clock_cycle
            remove
            Stage::Execute.get(state).mark_for_contention(self, instruction)
          end
          return instruction
        end
      end

      def memory_required?(instruction)
        ['LW', 'SW', 'L.D', 'S.D'].include?(instruction.operation)
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
        @pipelined = false
      end
    end
  end
end
