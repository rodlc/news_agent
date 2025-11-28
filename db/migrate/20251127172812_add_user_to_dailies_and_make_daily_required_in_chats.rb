class AddUserToDailiesAndMakeDailyRequiredInChats < ActiveRecord::Migration[7.1]
  def change
    add_reference :dailies, :user, null: false, foreign_key: true
    change_column_null :chats, :daily_id, false
  end
end
