# frozen_string_literal: true

module Concerns
  module BaseResourceHelper
    extend ActiveSupport::Concern
    # rubocop:disable Metrics/BlockLength
    class_methods do
      def field(field_name, **args, &)
        args[:translation_key] = if self < Avo::BaseAction
                                   compose_translation_key_for_action(field_name)
                                 else
                                   compose_translation_key_for_ressource(field_name)
                                 end
        super(field_name, **args, &)
      end

      def compose_translation_key_for_ressource(field_name)
        model_class_key = (respond_to?(:model_class) && model_class) || name.demodulize.delete_suffix("Resource")
        model_class_key = model_class_key.to_s.underscore

        "activerecord.attributes.#{model_class_key}.#{field_name}"
      end

      def compose_translation_key_for_action(field_name)
        [:actions, to_s.underscore.split("/"), field_name].join(".")
      end

      def actions(*items, **args)
        # (scan_action_klasses.compact + items.flatten.compact).uniq.each { |item| action(item) }
        all_items = (scan_action_klasses.compact + items.flatten.compact).uniq

        all_items = all_items.reject { |item| args[:exclude].include?(item) } if args[:exclude]

        # Sort items by MENU_POSITION, placing items without MENU_POSITION at the end
        sorted_items = all_items.sort_by do |item|
          item.const_defined?(:MENU_POSITION) ? item::MENU_POSITION : Float::INFINITY
        end

        sorted_items.each { |item| action(item) }
      end

      def scan_action_klasses
        mod = name.demodulize.delete_suffix("Resource").pluralize.to_s.underscore
        Dir.glob("*.rb", base: Rails.root.join("app/avo/actions/#{mod}")).filter_map do |path|
          "#{mod}/#{path.sub(/.rb\z/, '')}".camelize.constantize
        end
      end

      def filters(*items)
        items.flatten.each { |item| filter item }
      end

      def field_date_time(field_name, **args, &)
        date_format = args[:show_seconds] ? "dd.LL.yyyy HH:mm:ss" : "dd.LL.yyyy HH:mm"
        picker_format = args[:show_seconds] ? "d-m-Y H:i:s" : "d-m-Y H:i"
        args.merge!(
          as: :date_time,
          format: date_format,
          picker_format:
        )
        if args[:self]
          args[:self].send(:field, field_name, **args, &)
        else
          field(field_name, **args, &)
        end
      end

      def field_date(field_name, **args, &)
        args.merge!(
          as: :date,
          format: "dd.LL.yyyy",
          picker_format: "d-m-Y"
        )
        field(field_name, **args, &)
      end

      def field_link(field_name, **args)
        args[:as] = :text
        args[:as_html] = true
        field field_name, **args do |record, _resource, view|
          args[:shorten] = false if view == :show

          Avo::BaseResourceController.render RecloudCore::Fields::LinkField.new(record:, **args), layout: false
        end
      end

      def docs_link(path:, i18n_key:, scope: nil)
        host = ENV.fetch("REDOCS_URL", "")
        locale = I18n.locale == :de ? nil : "/#{I18n.locale}"
        href = [host, locale, path].compact.join
        title = scope ? I18n.t(i18n_key, scope:) : t(i18n_key)

        html = "<a href='#{href}' target='_blank' data-turbo='false'>" \
               "<div class='font-bold'>#{title}</div></a>"

        heading html, as_html: true
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
