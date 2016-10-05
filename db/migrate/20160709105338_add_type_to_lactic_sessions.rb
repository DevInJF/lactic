class AddTypeToLacticSessions < ActiveRecord::Migration
  def change
    add_column :lactic_sessions, :type, :integer, default: 0

  end
end
