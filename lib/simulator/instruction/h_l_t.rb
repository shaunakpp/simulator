# frozen_string_literal: true

module Simulator
  module Instruction
    class HLT
      attr_accessor :instruction
      def initialize(instruction)
        @instruction = instruction
      end
    end
  end
end
