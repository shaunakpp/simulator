# frozen_string_literal: true

module Simulator
  module Unit
    class MemoryUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?

        instruction.in_clock_cycles['MEM'] = state.clock_cycle
        @clock_cycles_pending = 1
        add(instruction)
      end

      def execute
        return if peek.nil?

        instruction = remove
        if memory_required?(instruction)
          if instruction.result[:memory_write]
            state.memory.convert_to_binary_and_store(
              instruction.result[:destination],
              instruction.result[:value]
            )
          end
        end
        @clock_cycles_pending -= 1
        instruction.out_clock_cycles['MEM'] = state.clock_cycle
      end

      def memory_required?(instruction)
        ['LW', 'SW', 'L.D', 'S.D'].include?(instruction.operation)
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
