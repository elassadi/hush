class BusinessHourResource < ApplicationBaseResource
  include Concerns::AccountField

  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.business_hours"

  self.title = :id
  self.includes = []

  self.model_class = "BusinessHour"

  field :jsonable, as: :belongs_to,
                   polymorphic_as: :jsonable, searchable: true, types: [::Merchant],
                   hide_on: %i[show index]

  field :day, as: :select, only_on: %i[new edit],
              display_with_value: true, include_blank: false,
              options: lambda { |args|
                         parent = args[:model].jsonable
                         ::BusinessHour.generate_day_options(parent)
                       }

  field :day, as: :select, only_on: %i[show index],
              options: lambda { |_args|
                         ::BusinessHour.generate_day_options(nil)
                       }

  field :start_time, as: :select, options: lambda { |_args|
    ::BusinessHour.generate_time_options
  }, display_with_value: true, include_blank: false, default: -> { "09:00" }
  field :end_time, as: :select, options: lambda { |_args|
    ::BusinessHour.generate_time_options
  }, display_with_value: true, include_blank: false, default: -> { "18:00" }
end
