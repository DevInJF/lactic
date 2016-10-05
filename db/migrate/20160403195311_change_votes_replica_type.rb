class ChangeVotesReplicaType < ActiveRecord::Migration
  def change
    remove_column :session_replicas, :votes, :string, array: true

    add_column :session_replicas, :votes, :json, array: true, default: []
  end
end
