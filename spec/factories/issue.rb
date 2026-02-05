FactoryBot.define do
  factory :issue do
    account { ::Account.recloud }
    assignee { ::Current.user }
    device
    customer
  end
end
