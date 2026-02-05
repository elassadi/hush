module SupplierArticles
  class AddToArticlesOperation < BaseOperation
    attributes :supplier_article
    delegate :image_url, :sku, :ean, :supplier, :tax, :unit, :stock_status, :purchase_price, :article_name,
             :supplier_article_group, to: :supplier_article

    attr_reader :article

    def call
      result = add_to_articles

      supplier_article = result.success
      if result.success?
        # Event.broadcast(:supplier_article_activated,
        # supplier_article_id: supplier_article.id) if supplier_article.status_active?
        return Success(supplier_article)
      end

      Failure(result.failure)
    end

    private

    def add_to_articles
      @article = Article.by_account.find_by(ean: supplier_article.ean) || (yield create_article)
      attach_image
      yield create_supplier_source
      Success(supplier_article)
    end

    def create_article
      article = Article.by_account.create(
        article_group: ArticleGroup.find_or_create_by(
          name: supplier_article_group
        ),
        article_type: :basic,
        supplier:,
        name: article_name,
        ean:,
        default_retail_price: purchase_price,
        default_purchase_price: purchase_price,
        sku:
      )

      return Success(article) if article.valid?

      Failure(article.errors.full_messages)
    end

    def attach_image
      return if image_url.blank?
      return unless image_url.downcase.start_with?("http", "https")

      # file = URI.open(image_url)
      file = URI.parse(image_url).open

      article.images.attach(io: file, filename: File.basename(image_url), content_type: "image/jpg")
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Article failed to attach image url : #{image_url} Error: #{e}")
    end

    def create_supplier_source
      article.supplier_sources.create!(
        {
          article_name: article.name,
          article:,
          sku: supplier_article.sku,
          supplier: supplier_article.supplier,
          tax: supplier_article.tax,
          unit: supplier_article.unit,
          purchase_price: article.purchase_price,
          stock_status: supplier_article.stock_status
        }
      )
      Success(true)
    end
  end
end
