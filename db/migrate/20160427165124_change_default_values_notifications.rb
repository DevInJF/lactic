class ChangeDefaultValuesNotifications < ActiveRecord::Migration
  def change
    change_column :notifications, :invites, 'integer', default: 0
    change_column :notifications, :requests, 'integer', default: 0
    change_column :notifications, :timeline, 'integer', default: 0
    change_column :notifications, :users, 'integer', default: 0

  end
end
