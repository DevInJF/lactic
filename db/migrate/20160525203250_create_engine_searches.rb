class CreateEngineSearches < ActiveRecord::Migration
  def change
    create_table :engine_searches do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :keyword, index: true
      t.json :users, array: true, default: []
    end
  end
end
