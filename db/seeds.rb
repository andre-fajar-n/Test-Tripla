# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding data..."

# Clear existing data
Follow.delete_all
SleepRecord.delete_all
User.delete_all

# Create users
users = User.create!([
  { name: "Alice" },     # aktif
  { name: "Bob" },       # aktif
  { name: "Charlie" },   # aktif
  { name: "Diana" },     # no activity
  { name: "Evan" }       # no activity
])

alice   = users[0]
bob     = users[1]
charlie = users[2]
_diana   = users[3]
_evan    = users[4]

# Create sleep records (past week)
alice.sleep_records.create!(sleep_at: 3.days.ago.change(hour: 23), wake_at: 2.days.ago.change(hour: 7))
alice.sleep_records.create!(sleep_at: 1.day.ago.change(hour: 22), wake_at: Time.current.change(hour: 6))

bob.sleep_records.create!(sleep_at: 4.days.ago.change(hour: 22, min: 30), wake_at: 3.days.ago.change(hour: 6, min: 30))

charlie.sleep_records.create!(sleep_at: 6.days.ago.change(hour: 0), wake_at: 5.days.ago.change(hour: 8))
charlie.sleep_records.create!(sleep_at: 2.days.ago.change(hour: 1), wake_at: 2.days.ago.change(hour: 9))

# Create follow relationships
# Alice follows Bob & Charlie
alice.following << bob
alice.following << charlie

# Bob follows Alice
bob.following << alice

# Charlie follows Alice & Bob
charlie.following << alice
charlie.following << bob

# Diana & Evan intentionally have no activity

puts "Seeding completed!"
