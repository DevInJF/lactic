class ChangeNotificationsPrimaryKey < ActiveRecord::Migration
  def change
    execute "ALTER TABLE notifications DROP CONSTRAINT notifications_pkey"
    add_index :notifications, [:id, :month_date], :unique => true
  end
end
