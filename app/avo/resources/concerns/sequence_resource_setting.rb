# frozen_string_literal: true

module Concerns
  module SequenceResourceSetting
    extend ActiveSupport::Concern
    included do
      self.title = :title
      self.authorization_policy = GlobalDataAccessPolicy
      self.translation_key = "activerecord.attributes.#{to_s.underscore.gsub(/_resource/, '')}"
      field :sequence_id, as: :uuid, only_on: %i[show index]
    end
  end
end
