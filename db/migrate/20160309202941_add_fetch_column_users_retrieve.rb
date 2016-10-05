class AddFetchColumnUsersRetrieve < ActiveRecord::Migration
  def change
    add_column :contacts_retrieves, :last_fetch, :json, array: true, default: []

  end
end
