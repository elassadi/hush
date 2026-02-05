module Templates
  class InUseFilter < Avo::Filters::BooleanFilter
    self.name = I18n.t(:'filters.by_in_use_filter.name')

    def apply(_request, query, values)
      return query unless values['in_use']

      query.by_account.joins(:customer_notification_rules)
    end

    def options
      {
        in_use: I18n.t(:'boolean.human.true')
      }
    end
  end
end
