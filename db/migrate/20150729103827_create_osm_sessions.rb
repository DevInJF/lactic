class CreateOsmSessions < ActiveRecord::Migration
  def change
    create_table :osm_sessions do |t|

      t.timestamps null: false
    end
  end
end
