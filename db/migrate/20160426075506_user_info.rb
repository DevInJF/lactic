class UserInfo < ActiveRecord::Migration
  def change
    create_table :user_info do |t|
      # t.integer :id
      t.string :title
      t.json :locations, array: true, default: []
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
