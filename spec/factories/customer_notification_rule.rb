FactoryBot.define do
  factory :customer_notification_rule do
    account { ::Account.recloud }
  end
end
