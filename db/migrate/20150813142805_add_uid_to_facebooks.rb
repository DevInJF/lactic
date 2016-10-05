class AddUidToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :uid, :string
  end
end
