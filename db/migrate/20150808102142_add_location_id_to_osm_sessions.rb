class AddLocationIdToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :location_id, :string
  end
end
