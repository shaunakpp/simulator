# frozen_string_literal: true

module Simulator
  module Unit
    class MemoryUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?
        @clock_cycles_pending = 1
        add(instruction)
      end

      def execute
        return if peek.nil?

        instruction = peek
        # instruction.in_clock_cycles['MEM'] = state.clock_cycle

        if memory_required?(instruction)
          cache = Cache::DCache::Manager.get(state)
          cache.fetch(instruction)
          @clock_cycles_pending = cache.clock_cycles_to_burn
          if cache.clock_cycles_burned?
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
        @clock_cycles_required = state.configuration.memory
        @clock_cycles_pending = 1
        @pipelined = false
      end
    end
  end
end
