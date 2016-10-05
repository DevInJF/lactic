class AddMatchedUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :matched_user, :string
  end
end
