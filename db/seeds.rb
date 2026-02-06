# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
puts "-- Creating default admin user"

admin_email = "admin@example.com"
User.find_or_create_by(email: admin_email).tap do |user|
  user.name = "Admin"
  user.password = "123456"
  user.add_role(:admin) unless user.has_role?(:admin)

  user.save!
end
puts "Default admin user created"

puts "-- Creating sample board for admin user"
board = Board.find_or_create_by(name: "Sample Board", user: User.find_by(email: admin_email))
puts "Sample board created"

puts "-- Creating sample list for admin user"
List.find_or_create_by(name: "Sample List", board: board)
puts "Sample list created"
