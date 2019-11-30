# frozen_string_literal: true

module Simulator
  module Operand
    class Label
      attr_reader :label
      def initialize(label)
        @label = label
      end

      def to_s
        label
      end
    end
  end
end
