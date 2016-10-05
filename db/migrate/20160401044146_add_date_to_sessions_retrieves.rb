class AddDateToSessionsRetrieves < ActiveRecord::Migration
  def change
    add_column :sessions_retrieves, :month_date, :datetime
    add_index  :sessions_retrieves, :month_date

  end
end
