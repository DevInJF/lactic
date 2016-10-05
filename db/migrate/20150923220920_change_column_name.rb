class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :users, :oauth_token, :access_token
  end
end
