module Price
  class Beautifier
    attr_accessor :original_price

    def round_steps
      [
        { max: 10, step_value: 0.5, cent: 0.01, tolerance: 0 },
        { max: 30, step_value: 1, cent: 0.01, tolerance: 0.01 },
        { max: 100, step_value: 5, cent: 0.01, tolerance: 0.5 }
      ]
    end

    def initialize(original_price)
      @original_price = original_price
    end

    def perform
      step = detect_step
      div = (original_price.to_f - step[:tolerance]) / step[:step_value]
      fractual_rest = div - div.to_i
      div = div.to_i + 1 if fractual_rest.positive?
      (div * step[:step_value]) - step[:cent]
    end

    def detect_step
      round_steps.each do |step|
        return step if step[:max] + step[:tolerance] >= original_price
      end
      round_steps.last
    end

    class << self
      def perform(price)
        new(price).perform
      end
    end
  end
end
