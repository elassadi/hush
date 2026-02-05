# frozen_string_literal: true

module Concerns
  module AccountField
    extend ActiveSupport::Concern
    included do
      field :account, as: :belongs_to, only_on: :show, visible: lambda { |resource:|
        next false if resource.model.blank?

        resource.model.account.present? && Current.user.access_level_global?
      }
      # rubocop:todo Lint/UnusedBlockArgument
      field :account, as: :belongs_to, only_on: :index, visible: lambda { |resource:|
        Current.user.access_level_global?
      }
      # rubocop:enable Lint/UnusedBlockArgument
    end
  end
end
