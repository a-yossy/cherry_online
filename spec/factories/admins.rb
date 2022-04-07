FactoryBot.define do
  factory :admin do
    email { 'admin@test.com' }
    password { 'admin_test_password' }
  end
end
