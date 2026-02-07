# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
puts "-- AdminUser"
admin_email = "admin@example.com"
AdminUser.find_or_create_by(email: admin_email).tap do |user|
  user.name = "Admin"
  user.password = "123456"
  user.save!
end
puts "Default admin user created"

puts "-- User"
user_email = "user@example.com"
user = User.find_or_create_by(email: user_email).tap do |user|
  user.name = "Sample User"
  user.password = "123456"

  user.skip_confirmation!
  user.save!
end
puts "Sample user created"

puts "-- Board"
board = Board.find_or_create_by(name: "Sample Board", user: user)
puts "Sample board created"

puts "-- List"
list = List.find_or_create_by(name: "Sample List", board: board)
puts "Sample list created"

puts "-- Task"
Task.find_or_create_by(title: "Sample task", list: list)
puts "Sample list created"
