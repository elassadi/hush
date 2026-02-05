# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class IssueEntriesController < BaseResourceController
    private

    def save_model
      return super unless @view == :create

      result = IssueEntries::CreateTransaction.call(issue_entry_attributes:)

      if result.success?
        @model = result.success if result.success.present?
        return true
      end

      @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      nil
    end

    def issue_entry_attributes
      @model.attributes.slice(
        *%w[issue_id article_id repair_set_id article_name category qty price]
      )
    end
  end
end
