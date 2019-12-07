# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      attr_accessor :sets, :current_set, :base
      def initialize
        @sets = []
        @sets << DCache::Set.new
        @sets << DCache::Set.new
      end

      def find(address)
        index =  0b10000 & address
        index = index >> 4
        sets[index]
      end

      def base_address(address)
        base = (address >> 4)
        base << 4
      end
    end
  end
end
