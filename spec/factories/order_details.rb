FactoryBot.define do
  factory :order_detail do
    sequence(:total_amount) { |i| 1000 * (i + 1) }
    paid { false }
    association :user
  end
end
