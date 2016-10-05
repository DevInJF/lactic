class AddEndDateTimeToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :end_date_time, :datetime
  end
end
