class AddFollowerIdToOsmSubscribers < ActiveRecord::Migration
  def change
    add_column :osm_subscribers, :follower_id, :string
  end
end
