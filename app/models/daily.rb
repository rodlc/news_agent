# app/models/daily.rb
class Daily < ApplicationRecord
  has_many :chats, dependent: :destroy 
end
