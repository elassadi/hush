FactoryBot.define do
  factory :purchase_order do
    account { ::Account.recloud }
    supplier
  end
end
