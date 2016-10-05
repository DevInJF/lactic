class AddIndexUsersRetrieve < ActiveRecord::Migration

    def change
      add_column :contacts_retrieves, :uid, :string
      add_index  :contacts_retrieves, :uid
      # add_reference :contacts_retrieves, :user, index: true
    end

end
