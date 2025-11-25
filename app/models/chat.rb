class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :daily

  has_many:messages
end
