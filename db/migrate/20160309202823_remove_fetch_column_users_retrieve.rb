class RemoveFetchColumnUsersRetrieve < ActiveRecord::Migration
  def change
    remove_column :contacts_retrieves, :last_fetch

  end
end
