class AddOsmIdToOsmUserInfo < ActiveRecord::Migration
  def change
    add_column :osm_user_infos, :osm_id, :string
  end
end
