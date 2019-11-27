# frozen_string_literal: true

module Simulator
  class InstructionSet
    attr_accessor :instructions, :labels
    def initialize
      @instructions = []
      @labels = {}
    end

    def fetch(index)
      instructions[index]
    end
  end
end
