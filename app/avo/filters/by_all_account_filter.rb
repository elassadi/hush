class ByAllAccountFilter < Avo::Filters::BooleanFilter
  self.name = self.name = I18n.t(:'filters.by_all_account_filter.name')

  self.visible = -> { Current.user.access_level_global? }

  def apply(_request, query, values)
    account_ids = if values.is_a?(Hash)
                    values.select { |_k, v| v }.keys
                  else
                    values
                  end

    return query if account_ids.blank?

    query.where(account_id: account_ids)
  end

  def options
    Account.status_active.map do |account|
      [account.id, account.name]
    end
  end
end
