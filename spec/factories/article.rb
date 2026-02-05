FactoryBot.define do
  factory :article do
    name { Faker::Commerce.product_name }
    sku { Faker::Code.asin }
    article_group
    default_retail_price { Faker::Commerce.price }
  end
end
