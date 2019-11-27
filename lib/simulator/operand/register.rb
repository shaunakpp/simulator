# frozen_string_literal: true

module Simulator
  module Operand
    class Register
      attr_reader :register
      def initialize(register)
        @register = register
      end
    end
  end
end
