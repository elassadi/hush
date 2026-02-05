class StockItem < ApplicationRecord
  MODEL_PREFIX = "sti".freeze
  include AccountOwnable

  string_enum :status, %w[unavailable available consumed deleted], _default: :unavailable

  belongs_to :article
  belongs_to :stock_area, inverse_of: :stock_items
  has_one :stock_location, through: :stock_area

  has_many :stock_movements

  def add_to_stock_quantity(qty)
    update_stock_quantity(qty)
  end

  def substract_from_stock_quantity(qty)
    update_stock_quantity(qty * -1)
  end

  private

  def update_stock_quantity(qty)
    update(in_stock: in_stock + qty)
  end
end
