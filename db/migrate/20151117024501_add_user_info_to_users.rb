class AddUserInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_info, :string
  end
end
