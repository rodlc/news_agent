class ChangeDailyIdToNullableInChats < ActiveRecord::Migration[7.1]
  def change
    # On change la colonne daily_id pour autoriser null
    change_column_null :chats, :daily_id, true
  end
end
