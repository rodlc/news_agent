# db/migrate/xxxxx_create_messages.rb
class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.text :content, null: false
      t.string :direction, null: false # "user" ou "assistant"

      t.timestamps
    end
  end
end
