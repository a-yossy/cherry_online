FactoryBot.define do
  factory :web_book_author do
    association :web_book
    association :author
  end
end
