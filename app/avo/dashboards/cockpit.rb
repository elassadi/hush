class Cockpit < Avo::Dashboards::BaseDashboard
  self.id = "cockpit"
  self.name = "Cockpit"
  # self.description = "Tiny dashboard description"
  # self.grid_cols = 3
  self.visible = lambda {
    true
  }

  # cards go here
  # card UsersCount

  self.grid_cols = 3

  card AnnouncementCard
  card NotConfirmedCalendarEntryMetric
  card OpenIssueMetric
  card IssueAreaChart
  card IssueSourceAreaChart
  # card ExampleScatterChart
  # card PercentDone
  # card AmountRaised
  # card ExampleLineChart
  # card ExampleColumnChart
  # card ExamplePieChart
  # card ExampleBarChart
end
