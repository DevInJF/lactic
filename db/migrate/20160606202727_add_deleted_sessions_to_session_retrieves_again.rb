class AddDeletedSessionsToSessionRetrievesAgain < ActiveRecord::Migration
  def change
    add_column :sessions_retrieves, :deleted_sessions, :string, array: true, default: []

  end
end
