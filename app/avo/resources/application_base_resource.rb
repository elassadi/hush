class ApplicationBaseResource < Avo::BaseResource
  include Concerns::BaseResourceHelper

  self.keep_filters_panel_open = true
  # silence the warning from avo
  self.model_class ||= Document

  class << self
    # TODO: remove
    def sidebar_field_date_time(context, field_name, **args, &)
      date_format = args[:show_seconds] ? "dd.LL.yyyy HH:mm:ss" : "dd.LL.yyyy HH:mm"
      args.merge!(
        as: :date_time,
        format: date_format,
        picker_format: "d-m-Y"
      )
      context.field(field_name, **args, &)
    end
    alias :avo_field :field

    def add_stimulus_actions(args)
      stimulus_args = args[:stimulus]
      args[:html] ||= {}
      Array(stimulus_args[:view]).each do |view|
        args[:html][view] = { input: { data: { action: stimulus_args[:action] } } }
      end
      args
    end

    def add_price_field!(args)
      args.merge!(
        {
          format_using: lambda { |value|
            next value if %i[new edit].include?(view)

            ActionController::Base.helpers.number_to_currency(value)
          }
        }
      )
    end

    def add_date_time_field!(args)
      date_format = args[:show_seconds] ? "dd.LL.yyyy HH:mm:ss" : "dd.LL.yyyy HH:mm"
      picker_format = args[:show_seconds] ? "d-m-Y H:i:s" : "d-m-Y H:i"
      args.merge!(
        as: :date_time,
        format: date_format,
        picker_format:
      )
    end

    def add_heading_field!(name, args)
      return if args[:name].present?

      args.merge!(
        name: I18n.t(name, scope: "#{translation_key}.headers")
      )
    end

    def __docs_link(path:, i18n_title:)
      host = ENV.fetch("REDOCS_URL")
      locale = I18n.locale == :de ? nil : "/#{I18n.locale}"
      href = [host, locale, path].compact.join

      html = "<a href='#{href}' target='_blank' data-turbo='false'>" \
             "<div class='font-bold'>#{t(i18n_title)}</div></a>"

      heading html, as_html: true
    end

    def add_upgrade_help!(args)
      return unless args[:feature_required]

      feature = args.delete(:feature_required)

      args.merge!(
        help: lambda { |resource:, orig_help:|
          return orig_help if Current.account.feature_available?(feature)

          I18n.t("helpers.account.feature_not_available")
        },
        orig_help: args[:help],
        readonly: -> { Current.account.feature_not_available?(feature) }
      )
    end

    def field(name, **args, &)
      args = add_stimulus_actions(args) if args.keys.detect { |k| k == :stimulus }
      # add_price_field!(args) if args[:as] == :price
      add_date_time_field!(args) if args[:as] == :date_time
      add_heading_field!(name, args) if args[:as] == :heading

      add_upgrade_help!(args)
      avo_field(name, **args, &)
    end
  end
end
