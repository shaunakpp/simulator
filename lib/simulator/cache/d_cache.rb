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
        index = address & 0b10000
        index = index >> 4
        @sets[index]
      end

      def base_address(address)
        (address >> 2) << 2
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
            set.find(address)
          elsif blocks_available?(base)
            set.find_empty
          else
            set.lru_block
          end
        block.address = address
        block.dirty = store
        set.toggle(block)
      end
    end
  end
end
