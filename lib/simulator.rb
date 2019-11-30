# frozen_string_literal: true

require 'zeitwerk'
require 'pry'

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module Simulator
  class Error < StandardError; end

  class Base
    attr_reader :configuration, :instruction_set, :register_state, :memory, :state
    def initialize(instructions_file, data_file, registers_file, config_file, _result_file)
      @instruction_set = Parser::InstructionParser.parse(instructions_file).instruction_set
      @configuration = Parser::ConfigurationParser.parse(config_file).configuration
      @register_state = Parser::RegisterParser.parse(registers_file).register_state
      @memory = Parser::DataParser.parse(data_file).memory
      @state = State.new(@configuration, @instruction_set, @register_state, @memory, 0, 1)
    end

    def run
      @fetch_stage = Stage::Fetch.get(state)
      @decode_stage = Stage::Decode.get(state)
      @execute_stage = Stage::Execute.get(state)
      @write_back_stage = Stage::WriteBack.get(state)

      loop do
        @write_back_stage.call
        @execute_stage.call
        @decode_stage.call
        @fetch_stage.call
        state.clock_cycle += 1
      end
      state.output_manager.print(state)
    end
  end
end

loader.eager_load
