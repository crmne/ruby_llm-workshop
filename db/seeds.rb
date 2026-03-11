# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Todo.create!(title: "Buy groceries", description: "Milk, eggs, bread, and coffee", priority: "high", due_date: Date.today)
Todo.create!(title: "Schedule dentist appointment", priority: "medium", due_date: Date.today)
Todo.create!(title: "Read RubyLLM docs", description: "Focus on tools and agents", priority: "low", due_date: 3.days.from_now)
Todo.create!(title: "Prepare workshop demo", description: "Test all code examples", priority: "high", due_date: 1.day.from_now)
Todo.create!(title: "Reply to Sarah's email", priority: "medium")
