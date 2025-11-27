# app/models/daily.rb
class Daily < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
end
