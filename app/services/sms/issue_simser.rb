module Sms
  class IssueSimser < BaseSimser
    attributes :issue, :template

    def record
      issue
    end
  end
end
