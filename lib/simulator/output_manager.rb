# frozen_string_literal: true

require 'tty-table'

module Simulator
  class OutputManager
    attr_accessor :output
    def initialize
      @output = TTY::Table.new
      @output << %w[Instruction IF ID EX WB RAW WAR WAW Struct]
    end

    def save(instruction)
      @output << [
        instruction.to_s,
        *instruction.out_clock_cycles.values.map(&:to_s),
        *instruction.hazards.values.map(&:to_s)
      ]
    end

    def print
      puts @output.render(:ascii)
    end
  end
end
