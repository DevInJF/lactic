class AddStartDateTimeToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :start_date_time, :datetime
  end
end
