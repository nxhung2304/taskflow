FactoryBot.define do
  factory :admin_user do
    email { "admin_#{SecureRandom.hex(4)}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    name { "Admin User" }
  end
end
