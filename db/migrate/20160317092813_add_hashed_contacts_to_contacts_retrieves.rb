class AddHashedContactsToContactsRetrieves < ActiveRecord::Migration
  def change
    add_column :contacts_retrieves, :hashed_fb_contacts, :json, array: true, default: []
    # add_column :contacts_retrieves, :array, :string
    # add_column :contacts_retrieves, :true, :string
  end
end
