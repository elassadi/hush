# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    account { ::Account.recloud }
    company_name { Faker::Company.name }
  end
end
