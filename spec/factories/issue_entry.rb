FactoryBot.define do
  factory :issue_entry do
    account { ::Account.recloud }
    price { 100 }
    article_name { "MyString" }
  end
end
