module Templates
  class ParseOperation < BaseOperation
    attributes :template, :data

    def call
      result = parse_template
      if result.success?
        # Event.broadcast(:stock_exported)
        return Success(result.success)
      end

      Failure(result.failure)
    end

    private

    def parse_template
      content = yield Converter::ApiClient.parse(body: template.body, data:, name: template.name)

      Success(content)
    end
  end
end
