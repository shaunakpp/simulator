# frozen_string_literal: true

module Simulator
  module Unit
    class FpAddUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def accept(instruction)
        return if busy?

        instruction.in_clock_cycles['EX'] = state.clock_cycle
        @clock_cycles_pending = state.configuration.fp_adder unless @pipelined
        add(instruction)
      end

      def execute
        instruction = peek
        return nil if instruction.nil?
        if @pipelined

          in_time = instruction.in_clock_cycles['EX']
          if state.clock_cycle - in_time >= @clock_cycles_required
            instruction = remove
            Stage::Execute.get(state).mark_for_contention(self, instruction)
            return instruction
          end
        else
          @clock_cycles_pending -= 1
          unless @clock_cycles_pending.positive?
            remove
            Stage::Execute.get(state).mark_for_contention(self, instruction)
            return instruction
          end
        end
      end

      def busy?
        return false if queue.empty?

        if @pipelined
          queue.size == clock_cycles_required
        else
          return @clock_cycles_pending.to_i.positive?
        end
        false
      end

      def parse_config
        @clock_cycles_required = state.configuration.fp_adder
        @clock_cycles_pending = state.configuration.fp_adder
        @pipelined = state.configuration.adder_pipelined
      end
    end
  end
end
