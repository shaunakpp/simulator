# frozen_string_literal: true

module Simulator
  Configuration = Struct.new(:fp_adder, :fp_multiplier, :fp_divider, :memory, :i_cache, :d_cache, :adder_pipelined, :multiplier_pipelined, :divider_pipelined)
end
