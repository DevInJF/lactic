class AddCreatorIdToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :creator_id, :string
  end
end
