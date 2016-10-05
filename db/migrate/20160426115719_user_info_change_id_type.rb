class UserInfoChangeIdType < ActiveRecord::Migration
  def change
    change_column :user_info, :id, 'bigint'
    # change_column :foobars, :something_id, 'bigint'
  end
end
