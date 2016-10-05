class AddNameToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :name, :string
  end
end
