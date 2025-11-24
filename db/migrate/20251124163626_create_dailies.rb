class CreateDailies < ActiveRecord::Migration[7.1]
  def change
    create_table :dailies do |t|

      t.timestamps
    end
  end
end
