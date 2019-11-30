module Simulator
  module Cache
    class DCache
      class Request
        attr_accessor :instruction,
                      :clock_cycle,
                      :clock_cycles_to_burn,
                      :stats_updated

        def initialize
          reset
        end

        def reset
          @instruction = nil
          @clock_cycle = nil
          @clock_cycles_to_burn = 0
          @stats_updated = false
        end
      end
    end
  end
end
