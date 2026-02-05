class EntriesSummaryTool < Avo::BaseResourceTool
  self.name = "EntriesSummaryTool"
  self.partial = "avo/entries_summary/turboframe"

  def visible?
    true
  end
end
