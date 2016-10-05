class AddInviteesToReplicaSessions < ActiveRecord::Migration
  def change
    add_column :session_replicas, :invitees, :json, array: true, default: []

  end
end
