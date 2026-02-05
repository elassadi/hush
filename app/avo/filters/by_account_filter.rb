class ByAccountFilter < Avo::Filters::BooleanFilter
  self.name = I18n.t(:'filters.by_account_filter.name')

  # self.visible = -> { Current.user.access_level_global? }

  def apply(_request, query, values)
    return query unless values['only_my_account']

    query.by_account.where.not(account_id: Account.recloud.id)
  end

  def options
    {
      only_my_account: I18n.t(:'boolean.human.true')
    }
  end
end
