# frozen_string_literal: true

module Simulator
  module Operand
    class Immediate
      attr_reader :value
      def initialize(value)
        @value = value
      end
    end
  end
end
