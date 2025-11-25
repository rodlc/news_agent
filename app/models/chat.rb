class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :daily, optional: true
  has_many :messages, dependent: :destroy
  
  validates :name, presence: true
end
