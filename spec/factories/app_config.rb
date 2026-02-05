# frozen_string_literal: true

FactoryBot.define do
  factory :app_config do
    key { "test" }
    value { "test_value" }
  end
end
