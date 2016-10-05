class AddLocationToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :location, :json
    add_column :user_infos, :location_id, :string

  end
end
