class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.references :daily, null: true, foreign_key: true # Optionnel

      t.timestamps
    end
  end
end
