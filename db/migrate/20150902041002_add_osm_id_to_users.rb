class AddOsmIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :osm_id, :string
  end
end
