class AddColumnsLacticSessionReplica < ActiveRecord::Migration
  def change

    add_column :session_replicas, :comments, :json, array: true, default: []
    add_column :session_replicas, :info, :json
    add_column :session_replicas, :votes, :string, array: true, default: []
    add_column :session_replicas, :origin_id, :string
    add_index  :session_replicas, :origin_id

  end
end
