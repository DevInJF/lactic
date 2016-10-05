class ChangePictureColumnOfUserInfos < ActiveRecord::Migration
  def change
    remove_column :user_infos, :picture
  end

end
