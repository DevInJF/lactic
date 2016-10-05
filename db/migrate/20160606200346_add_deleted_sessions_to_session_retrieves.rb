class AddDeletedSessionsToSessionRetrieves < ActiveRecord::Migration
  def change
    add_column :sessions_retrieves, :deleted_sessions, :json, array: true, default: []

  end
end
