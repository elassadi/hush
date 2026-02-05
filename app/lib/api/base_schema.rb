module Api
  class BaseSchema < Dry::Schema::Params
    class << self
      include Dry::Monads[:result, :do]
      def call(**args)
        result = new.call(**args)
        return Success(result) if result.success?

        Failure(result.errors)
      end
    end
  end
end
