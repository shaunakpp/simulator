# frozen_string_literal: true

module Simulator
  module Unit
    class WriteBackUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        return if peek.nil?

        instruction = remove

        instruction.out_clock_cycles['WB'] = state.clock_cycle
        state.register_state.busy.delete(instruction.operand_1.register)
        @clock_cycles_pending -= 1

        state.output_manager.save(instruction)
        return if instruction.result.empty?

        if instruction.result[:register_write]
          if instruction.result[:destination].start_with?('R')
            state.register_state.convert_to_binary_and_store(
              instruction.result[:destination],
              instruction.result[:value]
            )
          end
        end
        instruction.result = {}
        instruction
      end

      def accept(instruction)
        return nil if busy?

        instruction.in_clock_cycles['WB'] = state.clock_cycle
        add(instruction)
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
