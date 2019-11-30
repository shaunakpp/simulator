# frozen_string_literal: true

module Simulator
  module Instruction
    class LD
      attr_accessor :instruction, :state
      def initialize(instruction, state)
        @instruction = instruction
        @state = state
      end

      def execute; end
    end
  end
end
