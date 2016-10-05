class CreateNotificationTable < ActiveRecord::Migration
  def change
    create_table :notifications do |t|

      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :requests
      t.integer  :invites
      t.integer  :timeline
      t.integer  :users
    end
  end
end
