# frozen_string_literal: true

module Simulator
  module Unit
    class IntegerUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?

        instruction.in_clock_cycles['EX'] = state.clock_cycle
        @clock_cycles_pending = 1
        add(instruction)
      end

      def execute
        return if peek.nil?

        instruction = peek
        if instruction.result.empty?
          instruction_class = instruction.execution_class
          executor = instruction_class.new(self, state)
          executor.execute

          memory_unit = MemoryUnit.get(state)
          if memory_unit.busy?
          # hazard
          else
            @clock_cycles_pending -= 1
            instruction.out_clock_cycles['EX'] = state.clock_cycle
            memory_unit.accept(instruction)
          end
        else
          remove
          memory_unit = MemoryUnit.get(state)
          memory_unit.execute
        end
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
