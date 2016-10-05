class AddColumnsToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :description, :text, :deafult=>" "
  end
end
