class AddDailyReferenceToChat < ActiveRecord::Migration[7.1]
  def change
    add_reference :chats, :daily, null: false, foreign_key: true
  end
end
