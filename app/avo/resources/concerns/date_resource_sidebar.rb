# frozen_string_literal: true

module Concerns
  module DateResourceSidebar
    extend ActiveSupport::Concern
    included do
      sidebar do
        %i(updated_at created_at deleted_at).each do |field_name|
          field_date_time field_name, only_on: :show, show_seconds: true, self: self,
                                      visible: lambda { |resource:|
                                        next unless resource&.record

                                        resource.record[field_name].present?
                                      },
                                      name: I18n.t("shared.#{field_name}")
        end
      end
    end

    class << self
      def with_fields(date_fields: %i(updated_at created_at deleted_at))
        Module.new do
          extend ActiveSupport::Concern
          included do
            sidebar do
              date_fields.each do |field_name|
                field_date_time field_name, only_on: :show, show_seconds: true,
                                            self: self, visible: lambda { |resource:|
                                              next unless resource&.record

                                              resource.record[field_name].present?
                                            },
                                            name: I18n.t("shared.#{field_name}")
              end
              # field :owner, as: :belongs_to, only_on: :show, visible: ->(resource:) {
              #   resource && resource.model[:owner_id].present?
              #   # todo: restrictview to account admin
              #   #resource.model.account.present? && Current.user.access_level_global?
              # }

              # field :merchant, as: :belongs_to, only_on: :show, visible: ->(resource:) {
              #   resource && resource.model[:merchant_id].present?
              #  }
            end
          end
        end
      end
    end
  end
end
