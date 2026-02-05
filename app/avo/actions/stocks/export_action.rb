module Stocks
  class ExportAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/solid/upload"
    # self.icon_class = "text-red-500"

    self.standalone = true
    self.may_download_file = true

    field :include_empty_stocks, as: :boolean

    # test
    self.visible = lambda do
      return false unless view == :index

      current_user.may?(:export, Stock.new)
    end

    def handle(**args)
      # No batch actions

      params = args[:fields]
      include_empty_stocks = params[:include_empty_stocks]

      result = authorize_and_run(:export, Stock.new) do
        export_stocks(include_empty_stocks:)
      end

      return unless result.success?

      download result.success, "export-#{object_id}.csv"
    end

    private

    def export_stocks(include_empty_stocks:)
      Stocks::ExportOperation.call(format: :cvs, include_empty_stocks:)
    end
  end
end
