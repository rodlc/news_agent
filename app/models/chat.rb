# app/models/chat.rb
class Chat < ApplicationRecord
  # Ajout de optional: true car un chat peut exister sans daily
  belongs_to :daily, optional: true 
  belongs_to :user
  
  has_many :messages
end
