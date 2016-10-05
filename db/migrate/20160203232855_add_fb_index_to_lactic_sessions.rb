class AddFbIndexToLacticSessions < ActiveRecord::Migration
  def change
    # add_column :lactic_sessions, :creator_fb_id, :string
    add_index :lactic_sessions, :creator_fb_id
  end
end
