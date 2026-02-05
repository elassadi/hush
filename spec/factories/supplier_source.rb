FactoryBot.define do
  factory :supplier_source do
    supplier
    sku { Faker::Number.number(digits: 10) }
    purchase_price { 10 }
    article_name { Faker::Name.name }
  end
end
