# frozen_string_literal: true

module Simulator
  class Memory
    attr_accessor :data, :busy

    def initialize
      @data = {}
      @busy = false
    end

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
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

    def busy?
      @busy
    end
  end
end
