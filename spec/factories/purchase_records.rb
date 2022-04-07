FactoryBot.define do
  factory :purchase_record do
    association :web_book
    association :user
    association :order_detail
  end
end
