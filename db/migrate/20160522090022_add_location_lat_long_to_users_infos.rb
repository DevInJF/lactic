class AddLocationLatLongToUsersInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :latitude, :float
    add_column :user_infos, :longitude, :float
    add_index :user_infos, [:latitude, :longitude]
  end
end
