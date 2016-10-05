class CreateSessionsRetrieve < ActiveRecord::Migration
  def change
    create_table :sessions_retrieves do |t|
      t.json :last_fetch, array: true, default: []
      t.json :last_hashed_fetch, array: true, default: []
      t.string :uid
      t.boolean :contact_sessions
    end
    add_index  :sessions_retrieves, :uid

  end
end
