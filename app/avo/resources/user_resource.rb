class UserResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[disabled none],
    info: %w[agent supervisor account],
    success: %w[active],
    warning: %w[admin],
    danger: %w[deleted global]
  }.freeze

  self.title = :name
  self.includes = %i[role account merchant]
  self.devise_password_optional = true
  self.authorization_policy = UserDataAccessPolicy
  self.hide_from_global_search = true
  self.resolve_query_scope = lambda { |model_class:|
    Current.user.account_admin? ? model_class.by_account : model_class.by_account.where(id: Current.user.id)
  }

  self.search_query = lambda {
    scope.ransack(name_matches: "%#{params[:q]}%", m: "or").result(distinct: false)
  }

  field :status, as: :status_badge, options: STATUS_OPTIONS

  with_options hide_on: [:new] do
    field :access_heading, as: :heading,
                           visible: ->(_args) { Current.user.admin? }
    field :access_level, as: :status_badge, options: STATUS_OPTIONS, visible: ->(_args) { Current.user.admin? }

    field :access_level, as: :select, hide_on: %i[show index new],
                         options: ->(_args) { ::User.human_enum_names(:access_level, translate: false).invert },
                         display_with_value: true, include_blank: false,
                         readonly: -> { !current_user.admin? }, visible: ->(_args) { Current.user.admin? }

    field :current_account, as: :belongs_to, readonly: -> { !current_user.admin? },
                            visible: ->(_args) { Current.user.admin? }
  end

  field :user_informations_heading, as: :heading
  field :merchant, as: :belongs_to, readonly: -> { !current_user.account_admin? }, hide_on: %i[new],
                   visible: ->(_args) { Current.user.account_admin? },
                   attach_scope: lambda {
                                   if parent.current_account
                                     query.where(account: parent.current_account).order(:company_name)
                                   else
                                     query.where(account: Current.user.current_account).order(:company_name)
                                   end
                                 }

  field :name, as: :text
  field :email, as: :text, link_to_resource: true
  field :confirmed, as: :boolean, only_on: %i[index]

  field :password_information, as: :heading_help, i18n_key: :heading_password_information, path: "/users/user",
                               hide_on: %i[index show edit]

  with_options hide_on: [:new] do
    field :password, as: :password, name: "User Password", required: false, show_on: [:edit],
                     help: I18n.t("helpers.user.password_help")
    field :password_confirmation, as: :password, name: "Password confirmation", required: false
  end

  # field :role, as: :status_badge, options: STATUS_OPTIONS, hide_on: :forms

  # TODO: BIG unknow why the lamba is executed at the server start ??
  # ,   attach_scope: -> { query.by_account.where.not(id: parent.role_ids) }
  field :role, as: :belongs_to,
               hide_on: %i[index],
               readonly: -> { record&.id == current_user.id || !current_user.account_admin? },
               visible: lambda { |resource:|
                          Current.user.account_admin? && (resource.model && resource.model.id != Current.user.id)
                        },
               attach_scope: lambda {
                               safe_query = if parent.current_account
                                              query.where(account: parent.current_account)
                                            else
                                              query.where(account: Current.user.current_account)
                                            end
                               Current.user.admin? ? safe_query : safe_query.visible_for_customer
                             }

  field :role, as: :status_badge, hide_on: :forms,
               format_using: ->(value) { value&.name }

  field :extra_information, as: :heading
  field :confirmed, as: :boolean, only_on: %i[index show], visible: ->(_args) { Current.user.admin? }
  field :locale, as: :status_badge, hide_on: :index

  field :locale, as: :select, hide_on: %i[show index new],
                 options: ->(_args) { ::User.human_enum_names(:locale).invert },
                 display_with_value: true, include_blank: false

  field :avatar, as: :file, is_image: true, as_avatar: :rounded, width: "200px", accept: "image/*",
                 link_to_resource: true, hide_on: %i[index new]

  field :api_heading, as: :heading, show_on: :forms, visible: lambda { |_args|
    Current.user.admin?
  }
  field :api_only, as: :boolean, hide_on: :index, readonly: -> { !current_user.admin? },
                   visible: ->(_args) { Current.user.admin? }

  field :api_tokens, as: :has_many
  field :versions, as: :has_many, use_resource: UserVersionResource

  actions [
    Users::ActivateAction,
    Users::DisableAction,
    Users::CreateApiTokenAction,
    Users::LoginAsAction
  ]

  filter ByAllAccountFilter
  filter Users::SystemByRoleFilter
  filter Users::AccountByRoleFilter
end
