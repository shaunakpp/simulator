# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      class Request
        attr_accessor :instruction,
                      :clock_cycle,
                      :clock_cycles_to_burn,
                      :stats_updated,
                      :double,
                      :double_instruction_pending,
                      :double_stats_pending,
                      :hit
        def initialize
          reset
        end

        def reset
          @instruction = nil
          @double = false
          @clock_cycle = nil
          @clock_cycles_to_burn = -1
          @stats_updated = false
          @double_instruction_pending = true
          @double_stats_pending = true
          @hit = {}
        end
      end
    end
  end
end
