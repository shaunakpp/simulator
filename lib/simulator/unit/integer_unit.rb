# frozen_string_literal: true

module Simulator
  module Unit
    class IntegerUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return nil if busy?

        @clock_cycles_pending = 1
        add(instruction)
      end

      def execute
        memory_unit = MemoryUnit.get(state)
        return if peek.nil? && memory_unit.peek.nil?

        # if cycles_elapsed?
        instruction = peek

        memory_unit.execute if memory_unit.peek
        return nil if instruction.nil?

        instruction.in_clock_cycles['EX'] = state.clock_cycle

        if instruction.result.empty?
          instruction_class = instruction.execution_class
          instruction_class.new(instruction, state).execute
          # if memory_unit.busy?
          # TODO: hazard
          # else
          if memory_unit.accept(instruction)
            remove
          else
            instruction.hazards['Struct'] = true
          end

          return nil
        end

        remove if memory_unit.accept(instruction)
        # remove
        @clock_cycles_pending -= 1
        instruction
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
        @pipelined = false
      end
    end
  end
end
