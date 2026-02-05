class SupplierArticle < ApplicationRecord
  require "open-uri"

  AVAILABLE_ACTIONS = %i[
    import
    upload_attachments
  ].freeze

  MODEL_PREFIX = "spa".freeze
  include AccountOwnable

  string_enum :unit, Constants::UNITS, _default: :piece

  default_scope { includes(:supplier) }
  validates :sku, :article_name, :tax, :unit, :purchase_price, presence: true

  validates :purchase_price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :supplier, uniqueness: { scope: :sku }
  belongs_to :supplier
  has_many :stared_items, class_name: "Star", as: :stareable
  scope :stared, -> { joins(:stared_items).where(stars: { user_id: User.current_user.id }) }
  has_many :documents, as: :documentable, inverse_of: :documentable
  string_enum :stock_status, %w[available shortly_available upon_order unavailable unknown], _default: :unknown

  def to_basket
    stared_items.create!(user: User.current_user) unless stared_items.exists?(
      user: User.current_user
    )
  end

  def remove_from_basket
    stared_items.where(user: User.current_user).destroy_all
  end

  def create_article
    article = Article.find_by(sku:)
    return article if article.present?

    article = Article.create!(
      article_group: ArticleGroup.find_or_create_by(
        name: supplier_article_group
      ),
      article_type: :basic,
      supplier:,
      name: article_name,
      sku:,
      ean:,
      default_retail_price: purchase_price,
      default_purchase_price: purchase_price
    )

    attach_image(article)
    article
  end

  def attach_image(article)
    return if image_url.blank?

    # file = URI.open(image_url)
    file = URI.parse(image_url).open

    article.images.attach(io: file, filename: File.basename(image_url), content_type: "image/jpg")
  rescue OpenURI::HTTPError => e
    Rails.logger.error("Article image import failed url: #{image_url} Error: #{e}")
  end

  def create_supplier_source
    source = SupplierSource.create(
      supplier_source_data
    )
    article.supplier_sources << source
    source
  end

  def import_article
    self.article = create_article
    source = create_supplier_source
    save
    source
  end

  def can_import?
    true
  end

  private

  def supplier_source_data
    {
      article_name: article.name,
      article:,
      sku:,
      ean:,
      supplier:,
      tax:,
      unit:,
      purchase_price: article.purchase_price,
      stock_status:
    }
  end
  class << self
    def import_articles(supplier_articles)
      supplier_articles.each(&:import_article)
    end

    def ransackable_scopes(_opts)
      [:basket_articles]
    end

    def basket_articles(_query)
      where(id: SupplierArticle.stared)
    end

    def to_basket(articles)
      articles.each(&:to_basket)
    end

    def remove_from_basket(articles)
      articles.each(&:remove_from_basket)
    end

    def basket_empty?
      SupplierArticle.stared.none?
    end

    def clean_basket
      Star.where(stareable: SupplierArticle.stared).destroy_all
    end

    def basket_to_repair_set
      return if basket_empty?

      articles = SupplierArticle.stared.map do |supplier_article|
        supplier_article.import_article unless supplier_article.article
        supplier_article.article
      end

      set = RepairSet.new
      set.name = " set with Imported articles "
      set.device_failure_category = DeviceFailureCategory.first
      set.device_model = DeviceModel.first
      set.description = " Achtung Bitte Set editieren , Fehlerkategorien , Gerätedaten usw... "
      set.save!
      articles.each do |article|
        set.repair_set_entries.create!(
          article:,
          qty: 1
        )
      end
      clean_basket
      set
    end
  end
end
