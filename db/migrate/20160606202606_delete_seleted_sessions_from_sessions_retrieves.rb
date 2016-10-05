class DeleteSeletedSessionsFromSessionsRetrieves < ActiveRecord::Migration
  def change
    remove_column :sessions_retrieves, :deleted_sessions
  end
end
