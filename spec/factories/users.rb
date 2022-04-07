FactoryBot.define do
  factory :user do
    sequence(:name) { |i| "name#{i}" }
    sequence(:email) { |i| "user#{i}@test.com" }
    password { 'user_test_password' }
  end
end
