class AddDeletedSessionsToSessionRetrievesOnceAgain < ActiveRecord::Migration
  def change
    add_column :sessions_retrieves, :deleted_sessions, :text, array: true, default: []

  end
end
