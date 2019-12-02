# frozen_string_literal: true

require 'tty-table'

module Simulator
  class OutputManager
    attr_accessor :output, :result_file
    def initialize(result_file)
      @output = TTY::Table.new
      @output << %w[Instruction IF ID EX WB RAW WAR WAW Struct]
      @count = 0
      @raw_output = []
      @result_file = result_file
    end

    def save(instruction)
      # @raw_output << instruction
      @raw_output << [
        instruction.to_s,
        *instruction.out_clock_cycles.values.map(&:to_s),
        *instruction.hazards.values.map(&:to_s)
      ]
    end

    def build_table
      @raw_output.sort_by! { |x| x[1].to_i }
      @raw_output.each do |instruction|
        @output << instruction
      end
    end

    def i_cache_stats(state)
      i_cache = Cache::ICache.get(state)
      str = <<~STR
        Total number of access requests for instruction cache: #{i_cache.cache_stats[:requests]}
        Number of instruction cache hits: #{i_cache.cache_stats[:hits]}
      STR
      str
    end

    def d_cache_stats(state)
      d_cache = Cache::DCache::Manager.get(state)
      str = <<~STR
        Total number of access requests for data cache: #{d_cache.cache_stats[:requests]}
        Number of data cache hits: #{d_cache.cache_stats[:hits]}
      STR
      str
    end

    def print(state)
      build_table
      f = File.open(result_file, 'w')

      puts @output.render(:basic)
      f.puts @output.render(:basic)

      puts "\n"
      f.puts "\n"

      puts i_cache_stats(state)
      f.puts i_cache_stats(state)

      puts "\n"
      f.puts "\n"

      puts d_cache_stats(state)
      f.puts d_cache_stats(state)

      f.close
    end
  end
end
