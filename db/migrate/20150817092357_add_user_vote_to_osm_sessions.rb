class AddUserVoteToOsmSessions < ActiveRecord::Migration
  def change
    add_column :osm_sessions, :user_vote, :string , array: true , default: []
  end
end
