# frozen_string_literal: true

class UpdateRepairSetPricesJob < ApplicationJob
  def perform(article_id)
    update_repair_set_prices(article_id)
  end

  private

  def update_repair_set_prices(article_id)
    repair_set_entries = RepairSetEntry.includes(:repair_set).where(article_id:)

    repair_sets_to_update = repair_set_entries.map(&:repair_set).uniq

    repair_sets_to_update.each(&:update_set_price)
  end
end
