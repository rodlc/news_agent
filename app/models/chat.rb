# app/models/chat.rb
class Chat < ApplicationRecord
  belongs_to :daily
  belongs_to :user

  has_many :messages, dependent: :destroy

  validates :name, presence: true
end
