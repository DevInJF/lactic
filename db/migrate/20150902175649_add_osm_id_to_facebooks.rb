class AddOsmIdToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :osm_id, :string
  end
end
