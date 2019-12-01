# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      attr_accessor :sets
      def initialize
        @sets = []
        @sets << DCache::Set.new
        @sets << DCache::Set.new
      end

      def find(address)
        index =  0b10000 & address
        index = index >> 4
        @sets[index]
      end

      def base_address(address)
        base = (address >> 4)
        base << 4
      end

      def address_present?(address)
        set = find(address)
        base = base_address(address)
        set.address_present?(base)
      end

      def blocks_available?(address)
        set = find(address)
        set.blocks_available?
      end

      def lru_dirty?(address)
        set = find(address)
        set.lru_dirty?
      end

      def update(address, store)
        set = find(address)
        base = base_address(address)
        block =
          if address_present?(address)
            set.find(base)
          elsif blocks_available?(address)
            set.find_empty
          else
            set.lru_block
          end
        block.address = base
        block.dirty = store
        set.toggle(block)
      end
    end
  end
end
