class RemoveColumnFromUsersRetrieve < ActiveRecord::Migration
  def change
    remove_column :contacts_retrieves, :uid
    # remove_column :contacts_retrieves, :user_id
  end
end
