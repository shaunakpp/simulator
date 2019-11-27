# frozen_string_literal: true

module Simulator
  module Stage
    class Fetch
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state, :fetch_unit
      def initialize(state)
        @state = state
        @fetch_unit = Unit::FetchUnit.get(state)
      end

      def call
        instruction = fetch_unit.execute
        return if instruction.nil?

        decode = Decode.get(state)
        decode.accept(instruction)
      end

      def busy?
        fetch_unit.busy?
      end
    end
  end
end
