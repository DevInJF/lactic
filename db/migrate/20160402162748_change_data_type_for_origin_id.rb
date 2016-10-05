class ChangeDataTypeForOriginId < ActiveRecord::Migration
  def change
    remove_column :session_replicas, :origin_id, :string

    add_column :session_replicas, :origin_id, :integer
    add_index  :session_replicas, :origin_id
  end
end
