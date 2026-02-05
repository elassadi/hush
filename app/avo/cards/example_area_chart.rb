class ExampleAreaChart < Avo::Dashboards::ChartkickCard
  self.id = "user_signups"
  self.label = "User signups"
  self.chart_type = :area_chart
  self.description = "Some tiny description"
  self.cols = 2
  self.initial_range = 30
  self.ranges = {
    '7 days': 7,
    '30 days': 30,
    '60 days': 60,
    '365 days': 365,
    Today: "TODAY",
    'Month to date': "MTD",
    'Quarter to date': "QTD",
    'Year to date': "YTD",
    All: "ALL"
  }
  # self.chart_options = {library: {plugins: {legend: {display: true}}}}
  # self.flush = true
  # self.legend = true
  # self.scale = false
  # self.legend_on_left = true

  def query
    data = Array.new(3) do |index|
      {
        name: "Batch #{index}",
        data: Array.new(17) { |i| [i, Random.rand(32)] }
      }
    end

    result data
  end
end
