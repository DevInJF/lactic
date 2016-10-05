class CreateContactsRetrieve < ActiveRecord::Migration
  def change
    create_table :contacts_retrieves do |t|
      t.json :last_fetch
      # t.string :uid
      t.boolean :lactic_contacts
    end
  end
end
