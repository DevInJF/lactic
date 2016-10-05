class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.string :title
      t.text :about
      t.datetime :created_at
      t.datetime :updated_at
      t.string :name
    end
  end
end
