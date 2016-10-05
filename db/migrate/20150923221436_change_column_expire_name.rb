class ChangeColumnExpireName < ActiveRecord::Migration
  def change
    rename_column :users, :oauth_expires_at, :access_token_expiration_date

  end
end
