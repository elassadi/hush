class ExampleBarChart < Avo::Dashboards::ChartkickCard
  self.id = "example_bar_chart"
  self.label = "Example bar chart"
  self.chart_type = :bar_chart
  self.cols = 1
  self.flush = false
  self.legend = true
  self.scale = true
  self.legend_on_left = true

  def query
    data = Array.new(2) do |index|
      {
        name: "Batch #{index}",
        data: Array.new(4) { |i| [i, Random.rand(32)] }
      }
    end

    result data
  end
end
