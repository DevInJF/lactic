class AddPictureColumnToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :picture, :string
  end
end
