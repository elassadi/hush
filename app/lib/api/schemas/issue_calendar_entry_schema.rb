module Api
  module Schemas
    class IssueCalendarEntrySchema < ::Api::BaseSchema
      define do
        required(:customer).filled(::Api::Schemas::CustomerSchema.new)
        required(:merchant_id).filled(:integer)
        optional(:repair_set_id).filled(:integer)
        optional(:notes).filled(:string).value(max_size?: 510)
        required(:start_at).filled(:date_time).value(
          gteq?: Time.zone.now,
          lteq?: 1.month.from_now
        )
        required(:end_at).filled(:date_time).value(
          gteq?: Time.zone.now,
          lteq?: 1.month.from_now
        )
      end
    end
  end
end
