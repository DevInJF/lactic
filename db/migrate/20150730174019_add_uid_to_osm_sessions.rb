class AddUidToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :uid, :string
  end
end
