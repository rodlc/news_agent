class Message < ApplicationRecord
  belongs_to :chat
  
  validates :content, presence: true
  validates :direction, inclusion: { in: %w[user assistant] }
  
  # Ordre chronologique par défaut
  default_scope { order(created_at: :asc) }
end
