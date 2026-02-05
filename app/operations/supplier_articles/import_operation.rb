module SupplierArticles
  class ImportOperation < BaseOperation
    attributes :document, :supplier
    BULK_SIZE = 1000

    def call
      result = import_document
      if result.success?
        Event.broadcast(:supplier_articles_imported, document_id: document.id,
                                                     user_id: Current.user.id, supplier_id: supplier.id)
        return Success(document)
      end

      Failure(result.failure)
    end

    private

    def import_document
      yield validate_statuses

      clean_supplier_articles
      process_csv_data

      Success(document)
    end

    def validate_statuses
      Success(true)
    end

    def process_csv_data
      SmarterCSV.process(document_utf8_data, csv_import_options) do |chunk|
        collection = []
        chunk.each do |raw_data_hsh|
          collection << supplier_article_hash(raw_data_hsh)
        end
        SupplierArticle.insert_all(collection) if collection.present?
      end
    end

    def supplier_article_hash(raw_data)
      {
        uuid: "spa_" << SecureRandom.uuid.delete('-')[0..13],
        account_id: supplier.account_id,
        supplier_id: supplier.id,
        article_name: raw_data[:article_name],
        sku: raw_data[:sku],
        ean: raw_data[:ean],
        manufacturer_number: raw_data[:manufacturer_number],
        supplier_article_group: raw_data[:supplier_article_group],
        image_url: raw_data[:image_url],
        stock_status: map_stock_status(raw_data[:stock_status]),
        tax: AppConfig::GLOBAL_TAX,
        purchase_price: raw_data[:purchase_price].tr(",", "."),
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
        unit: :piece
      }
    end

    def validate_stock_status(stock_status)
      return "unknown" if stock_status.blank? || stock_status.empty?

      case stock_status.downcase
      when "available", "unavailable", "shortly_available", "upon_order"
        stock_status.downcase
      else
        "unknown"
      end
    end

    def map_stock_status(raw_stock_status)
      if %w[available unavailable shortly_available upon_order].include?(raw_stock_status.to_s.downcase)
        return raw_stock_status.to_s.downcase
      end
      return "unknown" unless raw_stock_status.is_a?(Numeric)

      %w[
        unavailable
        available
        upon_order
        shortly_available
      ][raw_stock_status] || "unknown"
    end

    def document_utf8_data
      # file_temp = Tempfile.new
      # file_temp.binmode
      # file_temp.write(document.file.download)
      # file_temp.rewind
      # file_temp
      # b_inding.pry
      document_content = document.file.download
      document_content = document_content.force_encoding('ISO-8859-1').encode('UTF-8')
      string_io = StringIO.new(document_content)
      string_io.set_encoding(Encoding::UTF_8)
      string_io
    end

    def csv_import_options
      {
        chunk_size: 2,
        col_sep: ";",
        file_encoding: "utf-8",
        user_provided_headers: %i[
          sku article_name supplier_article_group ean manufacturer_number
          stock_status purchase_price packaging image_url
        ]
      }
    end

    def clean_supplier_articles
      ::SupplierArticle.where(supplier:).delete_all
    end
  end
end
