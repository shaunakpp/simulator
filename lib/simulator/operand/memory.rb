# frozen_string_literal: true

module Simulator
  module Operand
    class Memory
      attr_reader :offset, :register
      def initialize(offset, register)
        @offset = offset
        @register = register
      end

      def to_s
        "#{offset}(#{register})"
      end
    end
  end
end
