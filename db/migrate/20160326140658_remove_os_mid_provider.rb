class RemoveOsMidProvider < ActiveRecord::Migration
  def change
    remove_column :users, :osm_id, :string
    remove_column :users, :provider, :string
  end
end
