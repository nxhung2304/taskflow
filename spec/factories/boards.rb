FactoryBot.define do
  factory :board do
    sequence(:name) { |n| "Board #{n}" }
    description { "A test board" }
    color { "#FF5733" }
    visibility { true }
    user
  end
end
