class AddSharedOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :shared, :boolean, :deafult=>true
  end
end
