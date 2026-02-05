module Stocks
  class ExportOperation < BaseOperation
    attributes :format, :include_empty_stocks

    def call
      result = export_stocks
      if result.success?
        Event.broadcast(:stock_exported)
        return Success(result.success)
      end
      Failure(result.failure)
    end

    private

    def export_stocks
      columns = %w(id article_name in_stock price)
      content = CSV.generate(headers: true) do |csv|
        csv << columns

        query = Stock.includes(:article).by_account
        query = query.where("in_stock > 0 ") unless include_empty_stocks

        query.each do |record|
          next if record.article.blank?

          csv << [
            record.id,
            record.article&.name,
            record.in_stock,
            record.article&.default_purchase_price
          ]
        end
      end

      Success(content)
    end
  end
end
