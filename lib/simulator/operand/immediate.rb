# frozen_string_literal: true

module Simulator
  module Operand
    class Immediate
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def to_s
        value.to_s
      end
    end
  end
end
