FactoryBot.define do
  factory :page do
    sequence(:title) { |i| "page_title#{i}" }
    sequence(:body) { |i| "# body#{i}" }
    sequence(:page_order) { |i| i }
    association :web_book
  end
end
