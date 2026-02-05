# frozen_string_literal: true

module Concerns
  module ResourcesDefaultSetting
    extend ActiveSupport::Concern
    included do
      self.title = :uuid
      self.authorization_policy = GlobalDataAccessPolicy
      self.translation_key = "activerecord.attributes.#{to_s.underscore.gsub(/_resource/, '')}"
      field :uuid, as: :uuid
    end

    class << self
      def with_options(show_uuid: false)
        Module.new do
          extend ActiveSupport::Concern
          included do
            self.title = :uuid
            self.authorization_policy = GlobalDataAccessPolicy
            self.translation_key = "activerecord.attributes.#{to_s.underscore.gsub(/_resource/, '')}"
            field :uuid, as: :uuid, only_on: show_uuid if show_uuid
          end
        end
      end
    end
  end
end
