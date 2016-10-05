class AddFolloweeUidToOsmSubscribers < ActiveRecord::Migration
  def change
    add_column :osm_subscribers, :followee_uid, :string
  end
end
