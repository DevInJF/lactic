class AddPictureColumnOfUserInfosAgain < ActiveRecord::Migration
  def change
    add_column :user_infos, :picture, :oid

  end
end
