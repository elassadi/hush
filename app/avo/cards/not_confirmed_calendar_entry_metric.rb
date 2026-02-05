class NotConfirmedCalendarEntryMetric < Avo::Dashboards::MetricCard
  self.id = "calendar_entries_metric"
  self.label = "Anzahl nicht bestätigter Kalendereinträge"
  self.description = "Anzahl der Kalendereinträge, die noch nicht bestätigt wurden." \
                     "Diese Zahl sollte möglichst gering sein."
  self.cols = 1

  # self.initial_range = "ALL"
  # self.ranges = ["ALL"]
  # self.ranges = [7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL"]
  # self.prefix = "$"
  # self.suffix = "%"
  self.refresh_every = 10.minutes

  # You have access to context, params, range, current dashboard, and current card
  def query
    from = Time.zone.now
    scope = CalendarEntry.by_account.unconfirmed.where(entry_type: %w[repair regular])
                         .where(start_at: from..)

    result scope.count
  end
end
