# app/models/chat.rb
class Chat < ApplicationRecord
  belongs_to :daily, optional: true
  belongs_to :user

  has_many :messages, dependent: :destroy

  validates :name, presence: true
end
