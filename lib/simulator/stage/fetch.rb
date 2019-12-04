# frozen_string_literal: true

module Simulator
  module Stage
    class Fetch
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state, :fetch_unit
      def initialize(state)
        @state = state
        @fetch_unit = Unit::FetchUnit.get(state)
        @halt = false
      end

      def call
        if @halt
          unless stages_busy?
            instruction = fetch_unit.execute
            return if instruction.nil?

            state.output_manager.save(instruction)
            state.output_manager.print(state)
            abort
          end
        end

        if @flush
          instruction = fetch_unit.peek || fetch_unit.fetch_next
          if instruction
            instruction.out_clock_cycles['IF'] = state.clock_cycle
            fetch_unit.queue = []
            @flush = false
            state.program_counter = @branch_pc
            state.output_manager.save(instruction)
          end
          return
        end

        instruction = fetch_unit.execute
        return if instruction.nil?

        decode = Decode.get(state)
        decode.accept(instruction)
      end

      def flush(branch_program_counter)
        @branch_pc = branch_program_counter
        @flush = true
      end

      def halt
        @halt = true
      end

      def stages_busy?
        stages = [
          Stage::Decode.get(state),
          Stage::Execute.get(state),
          Stage::WriteBack.get(state)
        ]

        stages.any?(&:busy?)
      end

      def accept
        fetch_unit.accept
      end

      def peek
        fetch_unit.peek
      end

      def busy?
        fetch_unit.busy?
      end
    end
  end
end
