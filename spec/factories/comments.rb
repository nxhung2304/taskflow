FactoryBot.define do
  factory :comment do
    content { "A test comment" }
    task
    user
  end
end
