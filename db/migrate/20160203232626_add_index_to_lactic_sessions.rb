class AddIndexToLacticSessions < ActiveRecord::Migration
  def change
    add_column :lactic_sessions, :creator_id, :string
    add_index :lactic_sessions, :creator_id
  end
end
