# frozen_string_literal: true

module Simulator
  module Stage
    class Fetch
      def self.get(state)
        @get ||= new(state)
      end

      attr_accessor :state, :fetch_unit
      def initialize(state)
        @state = state
        @fetch_unit = Unit::FetchUnit.get(state)
        @halt = false
      end

      def call
        if @halt
          unless stages_busy?
            instruction = fetch_unit.execute
            state.output_manager.save(instruction)
            state.output_manager.print
            abort
          end
        end

        if @flush
          @flush = false
          return
        end

        instruction = fetch_unit.execute
        return if instruction.nil?

        decode = Decode.get(state)
        decode.accept(instruction)
      end

      def flush
        @fetch_unit.queue = []
        @flush = true
      end

      def halt
        @halt = true
      end

      def stages_busy?
        stages = [
          self,
          Stage::Decode.get(state),
          Stage::Execute.get(state),
          Stage::WriteBack.get(state)
        ]

        stages.any?(&:busy?)
      end

      def accept
        fetch_unit.accept
      end

      def busy?
        fetch_unit.busy?
      end
    end
  end
end
