class CreateOsmSubscribers < ActiveRecord::Migration
  def change
    create_table :osm_subscribers do |t|

      t.timestamps null: false
    end
  end
end
