class AddFolloweeIdToOsmSubscribers < ActiveRecord::Migration
  def change
    add_column :osm_subscribers, :followee_id, :string
  end
end
