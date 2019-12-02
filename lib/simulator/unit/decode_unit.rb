# frozen_string_literal: true

module Simulator
  module Unit
    class DecodeUnit < Base
      def self.get(state)
        @get ||= new(state)
      end

      def execute
        return if peek.nil?

        instruction = peek

        instruction.in_clock_cycles['ID'] = state.clock_cycle

        if instruction.operation == 'HLT'
          instruction.out_clock_cycles['ID'] = state.clock_cycle
          state.output_manager.save(instruction)
          remove
          fetch_stage = Stage::Fetch.get(state)
          fetch_stage.flush
          fetch_stage.halt
          return nil
        end

        return nil unless check_hazards(instruction)

        remove
        instruction.out_clock_cycles['ID'] = state.clock_cycle

        if branch?(instruction)
          branch_taken = handle_branch(instruction)
          state.output_manager.save(instruction)
          return instruction unless branch_taken
        end

        unless branch?(instruction)
          state.register_state.busy << instruction.operand_1.register
        end

        @clock_cycles_pending -= 1

        instruction
      end

      # rubocop:disable Metrics/AbcSize
      def check_hazards(instruction)
        if state.register_state.busy?(instruction.operand_1)
          instruction.hazards['WAW'] = 'Y'
          return false
        end

        if state.register_state.busy?(instruction.operand_2) ||
           state.register_state.busy?(instruction.operand_3)
          instruction.hazards['RAW'] = 'Y'
          return false
        end

        execute_stage = Stage::Execute.get(state)
        if execute_stage.get_functional_unit(instruction).busy?
          instruction.hazards['Struct'] = 'Y'
          return false
        end

        true
      end
      # rubocop:enable Metrics/AbcSize

      def accept(instruction)
        return nil if busy?

        @clock_cycles_pending = 1
        add(instruction)
      end

      def branch?(instruction)
        %w[J BNE BEQ].include?(instruction.operation)
      end

      def handle_branch(instruction)
        case instruction.operation
        when 'BNE', 'BEQ'
          instruction_class = instruction.execution_class
          branch_taken = instruction_class.new(instruction, state).execute
          label = instruction.operand_3.label
        when 'J'
          branch_taken = true
          label = instruction.operand_1.label
        end
        if branch_taken
          program_counter = state.instruction_set.labels[label]
          state.program_counter = program_counter
          state.register_state.busy.delete(instruction.operand_1.register)
          fetch_stage = Stage::Fetch.get(state)
          state.output_manager.save(fetch_stage.peek) if fetch_stage.peek
          fetch_stage.flush
          return true
        end
        false
      end

      def parse_config
        @clock_cycles_required = 1
        @clock_cycles_pending = 1
      end
    end
  end
end
