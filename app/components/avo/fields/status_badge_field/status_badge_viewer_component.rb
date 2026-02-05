# frozen_string_literal: true

module Avo
  module Fields
    module StatusBadgeField
      class StatusBadgeViewerComponent < ViewComponent::Base
        def initialize(value:, options:, i18n_value:, i18n_value_tooltip: nil, shorten: true, link_to: nil)
          super
          @value = value
          @i18n_value = i18n_value
          @i18n_value_tooltip = i18n_value_tooltip
          @options = options
          @shorten = shorten
          @link_to = link_to
        end
      end
    end
  end
end
