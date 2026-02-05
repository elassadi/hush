# frozen_string_literal: true

module RecloudCore
  class ProfileItemComponent < ViewComponent::Base
    attr_reader :label, :icon, :path, :active, :target

    # rubocop:disable  Metrics/ParameterLists
    def initialize(label: nil, icon: nil, path: nil, active: :inclusive, target: nil, title: nil)
      @label = label
      @icon = icon
      @path = path
      @active = active
      @target = target
      @title = title
    end

    # rubocop:enable  Metrics/ParameterLists
    def title
      @title || @label
    end
  end
end
