# frozen_string_literal: true

module Simulator
  module Unit
    class FpDivideUnit < Base
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
        if @pipelined
          instruction = peek
          return nil if instruction.nil?

          in_time = instruction.in_clock_cycles['EX']
          if state.clock_cycle - in_time > @clock_cycles_required
            instruction = remove
            instruction.out_clock_cycles['EX'] = state.clock_cycle
            return instruction
          end
        else
          @clock_cycles_pending -= 1
          return remove unless busy?

          nil
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
        @clock_cycles_required = state.configuration.fp_divider
        @clock_cycles_pending = state.configuration.fp_divider
        @pipelined = state.configuration.divider_pipelined
      end
    end
  end
end
