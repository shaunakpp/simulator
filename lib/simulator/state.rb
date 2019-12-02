# frozen_string_literal: true

module Simulator
  class State
    attr_accessor :configuration, :instruction_set, :register_state, :memory,
                  :program_counter, :clock_cycle,
                  :output_manager
    # rubocop:disable Metrics/LineLength
    # rubocop:disable Metrics/ParameterLists
    def initialize(configuration, instruction_set, register_state, memory, program_counter, clock_cycle, result_file)
      @configuration = configuration
      @instruction_set = instruction_set
      @register_state = register_state
      @memory = memory
      @program_counter = program_counter
      @clock_cycle = clock_cycle
      @output_manager = OutputManager.new(result_file)
    end
    # rubocop:enable Metrics/LineLength
    # rubocop:enable Metrics/ParameterLists
  end
end
