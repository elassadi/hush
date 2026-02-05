class IssueWizard < Avo::BaseResourceTool
  self.name = "Issue Wizard"
  # self.partial = "avo/issues/create_wizard"
  self.partial = "avo/issue_entries/summary"
end
