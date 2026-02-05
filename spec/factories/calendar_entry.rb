# frozen_string_literal: true

FactoryBot.define do
  factory :calendar_entry do
    account { ::Account.recloud }
    merchant_id { ::Account.recloud.master_merchant.id }
  end
end
