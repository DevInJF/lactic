class RemoveNameFromOsmSession < ActiveRecord::Migration
  def change
    remove_column :osm_sessions, :name, :string
  end
end
