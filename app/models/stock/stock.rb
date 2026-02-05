class Stock < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "sto".freeze
  AVAILABLE_ACTIONS = %i[
    export
  ].freeze

  belongs_to :article
  has_many :stock_reservations, through: :article
  has_many :stock_items, through: :article

  def add_to_stock_quantity(qty)
    qty *= -1 if qty.negative?
    update_stock_quantity(qty)
  end

  def substract_from_stock_quantity(qty)
    update_stock_quantity(qty * -1)
  end

  def in_stock_available_by_area(stock_area)
    stock_item = (stock_items&.find_by(stock_area:) if stock_area)
    return 0 if stock_item.blank?

    [in_stock_available, stock_item.in_stock].min
  end

  def _in_stock_each_area
    stock_items.map do |stock_item|
      OpenStruct.new(stock_area: stock_item.stock_area, in_stock: stock_item.in_stock)
    end
  end

  def in_stock_each_area
    key_values = {}
    stock_items.each do |item|
      key_values["#{item.stock_area.stock_location.name} Area: #{item.stock_area.name}"] = item.in_stock
    end

    key_values
  end

  def in_stock_by_area(stock_area)
    stock_item = (stock_items&.find_by(stock_area:) if stock_area)
    return 0 if stock_item.blank?

    stock_item.in_stock
  end

  def in_stock_available_by_location(_stock_location)
    [sum_in_stock, in_stock_available].min
  end

  def sum_in_stock
    return 0 if stock_items.blank?

    stock_items.joins(:stock_location).where(
      stock_locations: {
        id: stock_location.id
      }
    ).sum(:in_stock)
  end

  def update_reservation_quantity_by(qty)
    update(
      reserved: reserved + qty,
      in_stock_available: in_stock_available - qty
    )
  end

  def reset_reservations
    update(
      reserved: 0,
      in_stock_available: in_stock
    )
  end

  def update_reservation_quantity!
    count = count_unfulfilled_reservations
    update(
      reserved: count,
      in_stock_available: in_stock - count
    )
  end

  def count_unfulfilled_reservations
    stock_reservations.not_status_fulfilled.sum(:qty)
  end

  def can_export?
    true
  end

  private

  def update_stock_quantity(qty)
    update(
      in_stock: in_stock + qty,
      in_stock_available: in_stock_available + qty
    )
  end
end
