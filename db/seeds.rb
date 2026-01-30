# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
puts "Creating default admin user"

User.find_or_create_by(email: "admin@example.com").tap do |user|
  puts "  - setting up user with email: #{user.email}, password: 123456"
  user.name = "Admin"
  user.password = "123456"
  user.add_role(:admin) unless user.has_role?(:admin)

  user.save!
end

puts "Default admin user created"
