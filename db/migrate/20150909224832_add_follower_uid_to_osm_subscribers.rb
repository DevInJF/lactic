class AddFollowerUidToOsmSubscribers < ActiveRecord::Migration
  def change
    add_column :osm_subscribers, :follower_uid, :string
  end
end
