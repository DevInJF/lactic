class AddLocationToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :location, :string
  end
end
