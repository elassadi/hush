# For more information regarding these settings check out our docs https://docs.avohq.io
Avo.configure do |config|

  SETTING_PAGES_PATHS ||= %w[
    /resources/global_settings
    /resources/application_settings
    /resources/booking_settings
    /resources/users
  ].freeze
  ## == Routing ==
  config.root_path = '/'

  # Where should the user be redirected when visting the `/avo` url
  config.home_path = '/dashboards/cockpit'
  #config.home_path = '/calendar_tool'

  ## == Licensing ==
  config.license = 'pro' # change this to 'pro' when you add the license key
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Set the context ==
  config.set_context do
    # Return a context object that gets evaluated in Avo::ApplicationController
  end

  ## == Authentication ==
  # config.current_user_method = {}
  # config.authenticate_with = {}


  config.current_user_method = :current_user


  ## == Authorization ==
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  # }
  config.raise_error_on_missing_policy = true
  config.authorization_client = "AvoAuthorizationClient"
  #config.authorization_client = "RecloudCore::Authorization::Client"

  ## == Localization ==
  # config.locale = "de"

  ## == Resource options ==
  config.resource_controls_placement = :left
  config.model_resource_mapping = {
    "CalendarEntry" => "CalendarEntryResource",
  }
  # config.default_view_type = :table
  # config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  config.via_per_page = 24
  config.id_links_to_resource = true
  config.cache_resources_on_index_view = false

  ## == Customization ==
  config.app_name = 'Recloud'
  config.search_results_count = 20
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.hide_layout_when_printing = false
  # config.full_width_container = true
  # config.full_width_index_view = false
  config.search_debounce = 600
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true
  # config.disabled_features = []
  # config.resource_controls = :right
  # config.tabs_style = :tabs # can be :tabs or :pills
  # config.buttons_on_form_footers = true
  config.cache_resource_filters = true
  #config.resource_default_view = :edit
  # == Branding ==
  if Rails.env.development?
    config.branding = {
      chart_colors: ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"],
      logo: "/hush-logo.png",
      logomark: "/logomark.png",
      placeholder: "/avo-assets/placeholder.svg",
      favicon: "/favs/dev-favicon.ico"
    }
  else
    config.branding = {
      colors: {
        background: "248 246 242",
        100 => "#c5eef1",
        400 => "#00d2c0",
#        500 => "#30a6a5",
        500 => "#009386",
        600 => "#02564f",

        # 100 => "#C5F1D4",
        # 400 => "#3CD070",
        # 500 => "#30A65A",
        # 600 => "#247D43",


        # 100 => "#CDF8F8",
        # 400 => "#3DD1D1",
        # 500 => "#30A6A6",
        # 600 => "#247D7D",
      },
      chart_colors: ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"],
      logo: "/hush-logo.png",
      logomark: "/logomark.png",
      placeholder: "/avo-assets/placeholder.svg",
      favicon: "/favs/favicon.ico"
    }
  end


  ## == Breadcrumbs ==
  # config.display_breadcrumbs = true
  # config.set_initial_breadcrumbs do
  #   add_breadcrumb "Home", '/avo'
  # end


  def i18n_menu_label(key)
    translation_key = "menus.#{key.to_s.pluralize}.label"

    return I18n.t(translation_key) if I18n.exists?(translation_key)
    "_#{translation_key}"
  end

  def i18n_group_menu_label(group, key=nil)
    translation_key = if key
      "menus.#{group}.#{key.to_s.pluralize}.label"
    else
      "menus.#{group}.label"
    end


    return I18n.t(translation_key) if I18n.exists?(translation_key)
    "_#{translation_key}"
  end

  def only_if_visible_menu(group, menu, **args)
    #label = group ? i18n_group_menu_label(group, menu) : i18n_menu_label(menu)
    label = i18n_group_menu_label(group, menu)
    resource menu, visible: -> {
      authorize current_user, menu.to_s.camelize.constantize, "read", raise_exception: false
    }, label: label, **args
  end


  def only_if_visible_group(group, **args, &block)
    args[:visible] = -> {
      args[:menus].detect do |menu|
        authorize current_user, menu.to_s.camelize.constantize, "read", raise_exception: false
      end.present?
    }
    group(i18n_group_menu_label(group), **args, &block)
  end


  def show_menu_group(group, menus, icon = nil)
    only_if_visible_group group, icon: , collapsable: true,  menus: menus, collapsed: false do
      menus.each do | menu |
        only_if_visible_menu group, menu
      end
    end
  end


  def show_menus(parent, menus)
    menus.each do | menu |
      only_if_visible_menu parent, menu
    end
  end





  def i18n_section_label(key)
    translation_key = "menus.sections.#{key}"

    return I18n.t(translation_key) if I18n.exists?(translation_key)
    "_#{translation_key}"
  end

  ## == Menus ==
  def account_sections

    section i18n_section_label("home"), icon: "dashboards" do
      all_dashboards
      link "Kalender", path: "/calendar_tool" if current_user.can?(:read, CalendarEntry)
    end

    section i18n_section_label("resources"), icon: "resources" do
      show_menu_group(:issues, %i(issue ), "heroicons/outline/clipboard-check")
      # show_menu_group(:issues, %i(issue repair_set purchase_order), "heroicons/outline/clipboard-check")
      # show_menu_group(:crm, %i(customer merchant supplier insurance account), "heroicons/outline/users")
      show_menu_group(:crm, %i(customer  merchant account), "heroicons/outline/users")
      #show_menu_group(:devices, %i(device device_manufacturer device_model device_model_category device_color device_failure_category),
      #                "heroicons/outline/device-mobile")
      #show_menu_group(:stocks, %i(stock_movement stock stock_reservation stock_location stock_area),
      #"heroicons/outline/archive-box-arrow-down")

      # show_menu_group(:articles, %i(article  article_group supplier_article supplier_source),
      #  "heroicons/outline/shopping-cart")
      show_menu_group(:articles, %i(article  article_group ),
        "heroicons/outline/shopping-cart")
      show_menu_group(:documents, %i(document template ), "heroicons/outline/document-magnifying-glass")
    end
  end

  def account_admin_sections


    section i18n_section_label("system"), icon: "heroicons/outline/cog-8-tooth" do
      show_menu_group(:settings, %i(global_setting application_setting booking_setting))
    end
    section i18n_section_label("user"), icon: "heroicons/outline/user" do
      show_menu_group(:users, %i(user role))
    end

  end




  def super_admin_sections

    section i18n_section_label("profil"), icon: "heroicons/outline/adjustments-horizontal" do
      show_menus(:profil, %i(notification))
    end
    section i18n_section_label("user"), icon: "heroicons/outline/user" do
      show_menu_group(:users, %i(account user role))
    end
    section i18n_section_label("system"), icon: "heroicons/outline/cog-8-tooth" do
      show_menu_group(:settings, %i(app_config))
    end

    section i18n_section_label("su_admin"), visible: ->{ current_user.admin?}, icon: "heroicons/outline/cog-8-tooth" do
      show_menu_group(:events, %i(sms_queue event event_job webhook_request webhook_request_job))
    end

    section i18n_section_label("admin_tools"), icon: "tools", visible: ->{ current_user.admin?} do
      all_tools
      link "Sidekiq", path: "/monitoring/sidekiq", target: :_blank
      link "ActiveStorage", path: "/rails/active_storage/blobs", target: :_blank
    end
  end

  ## == Menus ==
  config.main_menu = -> {
    if Current.user.admin?
      super_admin_sections
    else
      if Current.user.account_admin? && SETTING_PAGES_PATHS.any? { |path| request.path.start_with?(path) }
        account_admin_sections
      else
        account_sections
      end
    end
  }

  config.profile_menu = -> {
    link "Profile", path: "/resources/users/#{current_user.id}", icon: "user-circle"
  }
end

Rails.configuration.to_prepare do
  Avo::ApplicationController.include CurrentUserAndAudit
  Avo::ActionsController.prepend AvoPatches::ActionsController
end
