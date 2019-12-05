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
      @raw_output << [
        instruction.to_s,
        *instruction.stage_sequence,
        *instruction.hazards_sequence
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

    # rubocop:disable Metrics/LineLength
    def build_output(state)
      build_table
      "#{@output.render(:basic)}\n\n#{i_cache_stats(state)}\n#{d_cache_stats(state)}"
    end
    # rubocop:enable Metrics/LineLength

    def print(state)
      op = build_output(state)
      puts op
      f = File.open(result_file, 'w')
      f.puts op
      f.close
    end
  end
end
