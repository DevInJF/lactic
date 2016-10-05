class AddAboutToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_info, :about, :text
  end
end
