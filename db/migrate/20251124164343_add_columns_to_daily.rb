class AddColumnsToDaily < ActiveRecord::Migration[7.1]
  def change
    add_column :dailies, :title, :string, default: ""
    add_column :dailies, :summary, :text, default: ""
  end
end
