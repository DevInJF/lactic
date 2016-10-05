class AddExpiresAtToLacticMatch < ActiveRecord::Migration
  def change
    add_column :lactic_matches, :expires_at, :datetime
  end
end
