class AddAccessTokenExpireDateToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :access_token_expire_date, :datetime
  end
end
