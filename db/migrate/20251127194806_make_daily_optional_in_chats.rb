class MakeDailyOptionalInChats < ActiveRecord::Migration[7.1]
  def change
    change_column_null :chats, :daily_id, true
  end
end
