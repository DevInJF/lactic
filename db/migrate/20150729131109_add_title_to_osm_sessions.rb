class AddTitleToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :title, :string
  end
end
