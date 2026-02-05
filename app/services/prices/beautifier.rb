module Prices
  class Beautifier < BaseService
    attributes :original_price

    ROUMD_STEPS = [
      { max: 10, step_value: 0.5, cent: 0.01, tolerance: 0 },
      { max: 30, step_value: 1, cent: 0.01, tolerance: 0.01 },
      { max: 100, step_value: 5, cent: 0.01, tolerance: 0.5 }
    ].freeze

    def call
      Success(beautify_price)
    end

    private

    def beautify_price
      step = detect_step
      div = (original_price.to_f - step[:tolerance]) / step[:step_value]
      fractual_rest = div - div.to_i
      div = div.to_i + 1 if fractual_rest.positive?
      (div * step[:step_value]) - step[:cent]
    end

    def detect_step
      ROUMD_STEPS.each do |step|
        return step if step[:max] + step[:tolerance] >= original_price
      end
      ROUMD_STEPS.last
    end
  end
end
