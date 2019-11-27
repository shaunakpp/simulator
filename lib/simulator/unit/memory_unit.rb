# frozen_string_literal: true

module Simulator
  module Unit
    class MemoryUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?

        @clock_cycles_pending = if memory_required?(instruction)
                                  state.configuration.memory
                                else
                                  1
                                end
        add(instruction)
      end

      def execute
        return if peek.nil?

        instruction = peek
        # instruction.in_clock_cycles['MEM'] = state.clock_cycle

        if memory_required?(instruction)
          if instruction.result[:memory_write]
            state.memory.convert_to_binary_and_store(
              instruction.result[:destination],
              instruction.result[:value]
            )
          end
        end

        @clock_cycles_pending -= 1

        unless @clock_cycles_pending.positive?
          # instruction.out_clock_cycles['MEM'] = state.clock_cycle
          remove
          Stage::Execute.get(state).mark_for_contention(self, instruction)
        end
        instruction
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
