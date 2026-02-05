# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    account { ::Account.recloud }
  end
end
