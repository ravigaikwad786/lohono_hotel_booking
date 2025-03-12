# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Seeding villas and Schedule data..."

Villa.destroy_all
VillaSchedule.destroy_all

50.times do
  villa = Villa.create!(name: Faker::Address.unique.community, address: Faker::Address.city)
  
  (Date.new(2025, 1, 1)..Date.new(2025, 12, 31)).each do |date|
    VillaSchedule.create!(
      villa: villa,
      date: date,
      price: rand(30000..50000),
      available: [true, false].sample
    )
  end
end

puts "Seeding completed!"