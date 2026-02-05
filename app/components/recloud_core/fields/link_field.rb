# frozen_string_literal: true

module RecloudCore
  module Fields
    class LinkField < BaseViewComponent
      SHORTEN_SIZE = 10
      attributes :record, :text, :href
      optional_attributes title: nil, shorten: true, target: "_blank"

      def initialize(args = {})
        super
        %i(title href text).each do |key|
          instance_variable_set("@#{key}", capture_value("@#{key}"))
        end
        shorten_text
      end

      def capture_value(variable_name)
        return instance_variable_get(variable_name) unless instance_variable_get(variable_name).is_a?(Proc)

        instance_variable_get(variable_name).call(record)
      end

      def shorten_text
        return unless shorten && @text.present?

        @text = "#{@text[0..SHORTEN_SIZE]}..."
      end

      def render?
        @href.present? && @text.present?
      end
    end
  end
end
