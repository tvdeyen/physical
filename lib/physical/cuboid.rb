# frozen_string_literal: true
require 'measured'

module Physical
  class Cuboid
    attr_reader :dimensions, :weight

    def initialize(dimensions: [], dimension_unit: :cm, weight: 0, weight_unit: :g)
      @weight = Measured::Weight(weight, weight_unit).convert_to(:g)
      @dimensions = dimensions.map { |dimension| Measured::Length.new(dimension, dimension_unit).convert_to(:cm) }
      @dimensions.fill(Measured::Length(self.class::DEFAULT_LENGTH, dimension_unit), @dimensions.length..2)
    end

    def volume
      Measured::Volume(
        dimensions.map { |dim| dim }.map(&:value).reduce(&:*),
        :ml
      )
    end
  end
end