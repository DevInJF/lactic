class AddQueueColumnToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :queue, :json, array: true, default: []

  end
end
