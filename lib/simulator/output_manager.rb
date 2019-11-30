# frozen_string_literal: true

require 'tty-table'

module Simulator
  class OutputManager
    attr_accessor :output
    def initialize
      @output = TTY::Table.new
      @output << %w[Instruction IF ID EX WB RAW WAR WAW Struct]
      @count = 0
      @raw_output = []
    end

    def save(instruction)
      # @raw_output << instruction
      @output << [
        instruction.to_s,
        *instruction.out_clock_cycles.values.map(&:to_s),
        *instruction.hazards.values.map(&:to_s)
      ]
    end

    def print(state)
      # @raw_output.each do |instruction|
      # @output << [
      #   instruction.to_s,
      #   *instruction.out_clock_cycles.values.map(&:to_s),
      #   *instruction.hazards.values.map(&:to_s)
      # ]
      # end

      puts @output.render(:ascii)
      puts "\n"
      i_cache = Cache::ICache.get(state)
      puts "Total number of access requests for instruction cache: #{i_cache.cache_requests}"
      puts "Number of instruction cache hits: #{i_cache.cache_hits}"
    end
  end
end
