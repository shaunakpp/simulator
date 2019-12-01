# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      class Block
        attr_accessor :address, :dirty
        def initialize(address)
          @address = address
          @dirty = false
        end

        def free?
          address.nil?
        end
      end
    end
  end
end
