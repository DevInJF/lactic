class ChangeIdTypeForUsers < ActiveRecord::Migration
  def change
    change_column :users, :id, 'bigint'
    # change_column :foobars, :something_id, 'bigint'
  end
end
