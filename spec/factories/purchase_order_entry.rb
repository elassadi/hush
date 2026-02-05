FactoryBot.define do
  factory :purchase_order_entry do
    account { ::Account.recloud }
    price { 100 }
    qty { 2 }
    article
  end
end
