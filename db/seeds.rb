require 'faker'

puts "Cleaning database..."

#Chat.destroy_all
Message.destroy_all
Chat.destroy_all
Daily.destroy_all

User.destroy_all


puts 'Populating database...'
puts 'Creating users'


users = User.new(
    email: Faker::Internet.email,
    password: 'password123'
  )
  users.save!
puts 'Users done'

puts 'Creating dailies'
10.times do
  #daily = ''
  dailies = Daily.new(
    title: Faker::Lorem.sentence(word_count: 5),
    summary: Faker::Lorem.paragraph(sentence_count: 3)
  )
  dailies.save!
  end
puts 'Dailies done'

### Put to singular @Rodolphe

puts 'creating chats'
10.times do
  chats = Chat.new(
    name: Faker::Lorem.words(number: 3).join(' '),
    user: User.last,
    daily: Daily.last
  )
  chats.save!
  end
puts 'Chats done'


puts 'Creating messages'
25.times do
  messages = Message.new(
    content: Faker::Lorem.sentence(word_count: 10),
    direction: ['incoming', 'outgoing'].sample,
    chat: Chat.last
  )
  messages.save!
  end
puts 'Messages done'
