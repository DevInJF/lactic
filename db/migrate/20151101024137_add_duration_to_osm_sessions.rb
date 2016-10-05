class AddDurationToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :duration, :integer
  end
end
