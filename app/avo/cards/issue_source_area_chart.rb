class IssueSourceAreaChart < Avo::Dashboards::ChartkickCard
  self.id = "issue_source_area_chart"
  self.label = "Web Auftragseingänge vs vor Ort Aufträge"
  self.description = "Es werden die Auftragseingänge nach Quelle angezeigt über den ausgewählten Zeiträume."
  self.chart_type = :area_chart
  self.cols = 2
  self.rows = 2
  self.initial_range = 30
  self.ranges = {
    '7 Tage': 7,
    '30 Tage': 30,
    '60 Tage': 60,
    '90 Tage': 90
  }
  # self.ranges = {
  #   '7 Tage': 7,
  #   '30 Tage': 30,
  #   '60 Tage': 60,
  #   '365 Tage': 365,
  #   Heute: "TODAY",
  #   'Monat bis heute': "MTD",
  #   'Quartal bis heute': "QTD",
  #   'Jahr bis heute': "YTD",
  #   Alles: "ALL"
  # }
  # self.chart_options = {library: {plugins: {legend: {display: true}}}}
  self.flush = false
  self.scale = true
  self.legend_on_left = true

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
    start_date, end_date = date_range

    entity_data = {}

    entity_data["api"] = Issue.by_account.where(created_at: start_date..end_date)
                              .where("JSON_EXTRACT(JSON_UNQUOTE(metadata), '$.source') = 'api'")
                              .group("DATE(created_at)").count
                              .map { |date, count| [date.strftime("%Y-%m-%d"), count] }
    entity_data["backend"] = Issue.by_account.where(created_at: start_date..end_date)
                                  .where("JSON_EXTRACT(JSON_UNQUOTE(metadata), '$.source') = 'backend'")
                                  .where("status != 'canceld'")
                                  .group("DATE(created_at)").count
                                  .map { |date, count| [date.strftime("%Y-%m-%d"), count] }

    names = {
      "api" => "Web Auftragseingänge",
      "backend" => "Vor Ort Aufträge"
    }
    data = %w[api backend].map do |entity|
      {
        name: names[entity],
        data: entity_data[entity]
      }
    end
    result data
  end
end
