module Users
  class SystemByRoleFilter < Avo::Filters::BooleanFilter
    self.name = self.name = I18n.t(:'filters.by_role_filter.name')
    self.visible = lambda {
      Current.user.admin?
    }

    def apply(_request, query, values)
      role_ids = if values.is_a?(Hash)
                   values.select { |_k, v| v }.keys
                 else
                   values
                 end

      return query if role_ids.blank?

      query.where(role_id: Role.where(name: Role.where(id: role_ids).select(:name)))
    end

    def options
      # Extract the sub-hash
      query = Role.by_account.order(:name)

      if Current.user.access_level_global?
        query = Role.all.select('roles.name, MIN(roles.id) as id, MIN(roles.account_id) as account_id')
                    .group('roles.name')
                    .order(:name)
      end

      query.map do |role|
        [role.id, role.name]
      end
    end
  end
end
