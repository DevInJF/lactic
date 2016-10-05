class AddDeletedToLacticSessions < ActiveRecord::Migration
  def change
    add_column :lactic_sessions, :deleted, :boolean
    add_column :lactic_sessions, :date_deleted, :datetime
  end
end
