class AddOsmObjectidOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :osm_id, :string
  end
end
