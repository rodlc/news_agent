class Message < ApplicationRecord
  belongs_to :chat

  # Validations explicites (même si Rails gère automatiquement les timestamps)
  validates :content, presence: true
  validates :direction, presence: true, inclusion: { in: %w[user assistant] }
  validates :created_at, presence: true, on: :update
end
