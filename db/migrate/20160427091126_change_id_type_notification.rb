class ChangeIdTypeNotification < ActiveRecord::Migration
  def change
    change_column :notifications, :id, 'bigint'

  end
end
