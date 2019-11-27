# frozen_string_literal: true

module Simulator
  class State
    attr_accessor :configuration, :instruction_set, :register_state, :memory,
                  :program_counter, :clock_cycle
    # rubocop:disable Metrics/LineLength
    # rubocop:disable Metrics/ParameterLists
    def initialize(configuration, instruction_set, register_state, memory, program_counter, clock_cycle)
      @configuration = configuration
      @instruction_set = instruction_set
      @register_state = register_state
      @memory = memory
      @program_counter = program_counter
      @clock_cycle = clock_cycle
    end
    # rubocop:enable Metrics/LineLength
    # rubocop:enable Metrics/ParameterLists
  end
end
