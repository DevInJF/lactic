class ChangeNotificationIdToiddate < ActiveRecord::Migration
  def change
    add_column :notifications, :month_date, :datetime

  end
end
