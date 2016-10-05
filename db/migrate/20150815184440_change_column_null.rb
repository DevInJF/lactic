class ChangeColumnNull < ActiveRecord::Migration
  def change
    change_column_null(:osm_sessions, :title, false )
  end
end
