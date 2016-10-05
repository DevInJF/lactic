class CreateOsmUserInfos < ActiveRecord::Migration
  def change
    create_table :osm_user_infos do |t|
      t.string :title
      t.string :uid

      t.timestamps null: false
    end
  end
end
