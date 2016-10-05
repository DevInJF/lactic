class ChangeColumnFacebookName < ActiveRecord::Migration
  def change
    rename_column :facebooks, :access_token_expire_date, :access_token_expiration_date

  end
end
