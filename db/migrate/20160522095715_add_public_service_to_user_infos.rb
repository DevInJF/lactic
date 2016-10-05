class AddPublicServiceToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :public_service, :boolean

  end
end
