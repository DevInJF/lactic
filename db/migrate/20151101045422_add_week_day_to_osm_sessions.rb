class AddWeekDayToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :week_day, :integer
  end
end
