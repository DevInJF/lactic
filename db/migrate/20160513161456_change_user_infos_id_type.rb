class ChangeUserInfosIdType < ActiveRecord::Migration
  def change
    change_column :user_infos, :id, 'bigint'

  end
end
