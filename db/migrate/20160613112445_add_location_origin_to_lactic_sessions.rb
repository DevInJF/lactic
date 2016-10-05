class AddLocationOriginToLacticSessions < ActiveRecord::Migration
  def change
    add_column :lactic_sessions, :location_origin, :string
  end
end
