# frozen_string_literal: true

module Simulator
  class RegisterState
    attr_accessor :registers, :busy
    def initialize
      @registers = {}
      @busy = []
    end

    def [](key)
      registers[key]
    end

    def []=(key, value)
      registers[key] = value
    end

    def convert_to_int(key)
      self[key].to_i(2)
    end

    def binary(value)
      str = value.to_s(2)
      leading_zeros = '0' * (32 - str.size)
      leading_zeros + str
    end

    def convert_to_binary_and_store(key, value)
      self[key] = binary(value)
    end

    def busy?(operand)
      return false if operand.nil?
      return false if operand.is_a?(Operand::Immediate)
      return false if operand.is_a?(Operand::Memory)
      return false if operand.is_a?(Operand::Label)

      busy.include?(operand.register)
    end
  end
end
