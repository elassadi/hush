module CalendarEntries
  class FetchAllQuery < BaseQuery
    attributes :start_at, :end_date

    def call
      fetch_all
    end

    private

    def fetch_all
      entries = if start_at.present? && end_date.present?
                  query = CalendarEntry.by_account.where(start_at: start_at..end_date)
                  MerchantDataAccessPolicy.resolve(user: Current.user, model: query)
                else
                  CalendarEntry.none
                end

      Success(entries)
    end
  end
end
