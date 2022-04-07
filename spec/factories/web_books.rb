FactoryBot.define do
  factory :web_book do
    sequence(:title) { |i| "title#{i}" }
    sequence(:release_date) { |i| Date.current - (i + 2).days }
    sequence(:price) { |i| i * 1000 }
    sequence(:description) { |i| "# 説明#{i + 1}\n## 説明#{i + 1}\n***\n```ruby\ndef sum(a, b)\n\s\sa + b\nend\n```" }
    cover_image { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
    released { true }

    before(:create) do |web_book|
      web_book.pages.build(title: 'delete_title', body: 'delete_body')
    end
  end
end
