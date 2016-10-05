class ChangeColumn < ActiveRecord::Migration
  def change
    change_column :osm_sessions, :title, :string, :null => false
    # change_column :osm_sessions, :description, :text, :null => false

  end
end
