class ChangeAboutType < ActiveRecord::Migration
  def change
    remove_column :user_infos, :about

  end
end
