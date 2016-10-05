class AddAccessTokenToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :access_token, :string
  end
end
