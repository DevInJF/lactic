class AddingAboutTypeArrayText < ActiveRecord::Migration
  def change
    add_column :user_infos, :about, 'text', array: true, default: []

  end
end
