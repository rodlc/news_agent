require 'faker'

puts "Cleaning database..."

Message.destroy_all
Chat.destroy_all
Daily.destroy_all
User.destroy_all

puts 'Populating database...'

puts 'Creating users'
user = User.create!(
  email: Faker::Internet.email,
  password: 'password123'
)
puts "Users done - Created: #{user.email}"

puts 'Creating dailies'
dailies = []
10.times do
  daily = Daily.create!(
    title: Faker::Lorem.sentence(word_count: 5),
    summary: Faker::Lorem.paragraph(sentence_count: 3),
    user: user
  )
  dailies << daily
end
puts "Dailies done - Created #{dailies.count} dailies"

puts 'Creating chats'
chats = []
10.times do
  chat = Chat.create!(
    name: Faker::Lorem.words(number: 3).join(' '),
    user: user,
    daily: dailies.sample
  )
  chats << chat
end
puts "Chats done - Created #{chats.count} chats"

puts 'Creating messages'
25.times do
  Message.create!(
    content: Faker::Lorem.sentence(word_count: 10),
    direction: ['user', 'assistant'].sample,
    chat: chats.sample
  )
end
puts "Messages done - Created #{Message.count} messages"

puts "\n✅ Seed completed successfully!"
puts "Created:"
puts "  - #{User.count} user(s)"
puts "  - #{Daily.count} daily/dailies"
puts "  - #{Chat.count} chat(s)"
puts "  - #{Message.count} message(s)"
