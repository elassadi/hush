module Avo
  class IssueWizardController < Avo::ApplicationController
    def show
      @issue = Issue.new
    end
  end
end
