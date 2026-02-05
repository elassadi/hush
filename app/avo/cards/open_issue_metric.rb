class OpenIssueMetric < Avo::Dashboards::MetricCard
  self.id = "open_issue_metric"
  self.label = "Anzahl offener Aufträge"
  self.description = "Anzahl der Aufträge, die noch nicht erledigt wurden. Diese Zahl sollte möglichst gering sein."
  self.cols = 1
  self.initial_range = "30"
  self.ranges = {
    '7 Tage': 7,
    '30 Tage': 30,
    '60 Tage': 60,
    '90 Tage': 90
  }

  self.refresh_every = 10.minutes

  # You have access to context, params, range, current dashboard, and current card

  # rubocop:todo Metrics/AbcSize
  def date_range # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize
    start_date = 1.month.ago.beginning_of_day
    end_date = Time.current.end_of_day

    if range.present?
      if range.to_s == range.to_i.to_s
        start_date = DateTime.current - range.to_i.days
      else
        case range
        when "TODAY"
          start_date = DateTime.current.beginning_of_day
        when "MTD"
          start_date = DateTime.current.beginning_of_month
        when "QTD"
          start_date = DateTime.current.beginning_of_quarter
        when "YTD"
          start_date = DateTime.current.beginning_of_year
        when "ALL"
          start_date = Time.zone.at(0)
        end
      end
    end

    [start_date, end_date]
  end
  # rubocop:enable Metrics/AbcSize

  def query
    start_date, _end_date = date_range
    scope = Issue.by_account.where(created_at: start_date..).status_category_open

    result scope.count
  end
end
