# frozen_string_literal: true

module Simulator
  module Cache
    class DCache
      class Set
        attr_accessor :blocks, :lru
        def initialize
          @blocks = []
          @blocks << DCache::Block.new(nil)
          @blocks << DCache::Block.new(nil)
          @lru = 0
        end

        def toggle(block)
          @lru = blocks.first == block ? 1 : 0
        end

        def free?(index)
          @blocks[index].free?
        end

        def blocks_available?
          free?(0) || free?(1)
        end

        def address_present?(address)
          @blocks.any? { |block| block.address == address }
        end

        def lru_dirty?
          @blocks[lru].dirty
        end

        def find(address)
          @blocks.find { |block| block.address == address }
        end

        def find_empty
          @blocks.find(&:free?)
        end

        def lru_block
          @blocks[lru]
        end
      end
    end
  end
end
