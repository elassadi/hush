module Suppliers
  class FetchStockDataOperation < BaseOperation
    attributes :supplier

    FarolineReadDataError = Class.new(StandardError)

    # FARO_URL = "http://download.faro-com.de/csv/43559c350ce86bc684/mycsv.php" \
    #            "?key=2494356294ae69f73f686d178017e23d&mode=31733172".freeze

    def call
      result = fetch_and_update_stock
      document = result.success
      if document
        Event.broadcast(:supplier_article_import_requested, document_id: document.id, supplier_id: supplier.id,
                                                            current_user_id: supplier.account.user.id)
        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def fetch_and_update_stock
      yield validate_faroline_supplier

      content = yield read_data_from_url
      document = yield create_document(content)

      Success(document)
    end

    # rubocop:disable Security/Open
    def read_data_from_url
      content = URI.open(supplier.stock_api_url).read

      content.gsub!('\"', "")
      Success(content)
    end
    # rubocop:enable Security/Open

    def create_document(content)
      document = CsvDocument.new(status: :active, account_id: supplier.account_id, documentable: supplier)
      document.send(:generate_uuid)
      document.send(:assign_key)
      filename = "#{document.key}.csv"
      document.file.attach(io: StringIO.new(content), filename:, content_type: "text/csv")

      return Success(document) if document.save

      Failure(document.errors.full_messages)
    end

    def validate_faroline_supplier
      return Success(true) if supplier.company_name.casecmp("faroline").zero?

      Failure("Supplier is not a Faroline supplier")
    end
  end
end
