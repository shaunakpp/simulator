# frozen_string_literal: true

require 'pry'
module Simulator
  module Unit
    class Base
      attr_accessor :state, :queue
      attr_accessor :clock_cycles_required, :clock_cycles_pending, :pipelined

      def initialize(state)
        @state = state
        @queue = []
        parse_config
      end

      def execute; end

      def busy?
        return false if queue.empty?
        return true if queue.size == clock_cycles_required

        @clock_cycles_pending.to_i >= 0
      end

      def add(instruction)
        queue << instruction
      end

      def peek
        queue.first
      end

      def remove
        queue.shift
      end

      def empty?
        queue.empty?
      end

      def cycles_elapsed?
        @clock_cycles_pending != @clock_cycles_required
      end

      def parse_config
        raise NotImplementedError, "#{self.class} should parse config"
      end
    end
  end
end
