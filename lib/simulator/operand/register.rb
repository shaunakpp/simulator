# frozen_string_literal: true

module Simulator
  module Operand
    class Register
      attr_reader :register
      def initialize(register)
        @register = register
      end

      def to_s
        register.to_s
      end
    end
  end
end
