# frozen_string_literal: true

class MaintenanceJob < ApplicationJob
  def perform(**_args)
    @stats = {}
    ActiveRecord::Base.logger = nil
    archive_event_jobs

    fix_stock_reservations
    fix_supplier_sources

    AdminMailer.maintenance_job_mail(@stats).deliver_now
  end

  private

  def fix_stock_reservations
    miss_match_counter = 0
    miss_match_reservation_counter = 0

    Rails.logger.debug "Checking stock reservations" if Rails.env.development?

    StockReservation.status_pending.each do |reservation|
      Rails.logger.debug "." if Rails.env.development?
      next unless reservation.originator.issue.status_category.to_s == "done"

      Current.user = reservation.account.user
      reservation.destroy!
      miss_match_reservation_counter += 1
    end

    Rails.logger.debug "Checking articles" if Rails.env.development?

    Article.limit(5).each do |article|
      Rails.logger.debug "." if Rails.env.development?
      next unless (article.stock.in_stock_available != article.stock.in_stock -
        article.stock.count_unfulfilled_reservations) ||
                  article.stock.reserved != article.stock.count_unfulfilled_reservations

      Current.user = article.account.user
      miss_match_counter += 1
      article.stock.update_reservation_quantity!
    end
    @stats[:total_pending_reservations] = StockReservation.status_pending.count
    @stats[:miss_match_reservation_counter] = miss_match_reservation_counter
    @stats[:miss_match_counter] = miss_match_counter
  end

  def fix_supplier_sources
    mismatched_articles = 0

    Rails.logger.debug "Checking supplier sources" if Rails.env.development?

    Article.all.stockable.status_active.order(:account_id).limit(5).each do |article|
      Rails.logger.debug "." if Rails.env.development?
      Current.user = article.account.user
      old_supplier_id = article.supplier_id
      article.update_best_matching_supplier
      new_supplier_id = article.supplier_id
      mismatched_articles += 1 if new_supplier_id != old_supplier_id
    end
    @stats[:total_articles_checked] = Article.count
    @stats[:mismatched_articles] = mismatched_articles
  end
  def archive_event_jobs
    Rails.logger.debug "Archiving event jobs" if Rails.env.development?

    # Format the datetime to MySQL-compatible format
    cutoff_time = 2.days.ago.to_formatted_s(:db)

    query = <<-SQL
      INSERT IGNORE INTO event_jobs_archive SELECT * FROM event_jobs
      WHERE created_at < '#{cutoff_time}'
    SQL
    EventJob.connection.execute(query)

    query = <<-SQL
      INSERT IGNORE INTO events_archive SELECT * FROM events
      WHERE created_at < '#{cutoff_time}'
    SQL
    EventJob.connection.execute(query)

    EventJob.where("created_at < ?", 2.days.ago).delete_all
    Event.where("created_at < ?", 2.days.ago).delete_all
  end
end
