module Issues
  class CanceldFilter < Avo::Filters::BooleanFilter
    self.name = I18n.t(:'filters.issues.canceld_filter.name')
    def apply(_request, query, values)
      if values['hide_canceld']
        query.where.not(status: :canceld)
      else
        query
      end
    end

    def options
      {
        hide_canceld: I18n.t(:'filters.issues.canceld_filter.hide_canceld')
      }
    end

    def default
      {
        hide_canceld: true
      }
    end
  end
end
