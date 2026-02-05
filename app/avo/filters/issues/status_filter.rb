module Issues
  class StatusFilter < Avo::Filters::BooleanFilter
    self.name = 'workflow status filter'

    def apply(_request, query, values)
      statuses = if values.is_a?(Hash)
                   values.select { |_k, v| v }.keys
                 else
                   values
                 end

      return query if statuses.blank?

      query.where(status: statuses)
    end

    def options
      IssueWorkflow.human_workflow_statuses
    end

    def model_class; end
  end
end
