class CreateLacticLocationsTable < ActiveRecord::Migration
  def change
    create_table :lactic_locations do |t|
      t.float  :latitude
      t.float  :longitude
      t.datetime :created_at
      t.datetime :updated_at
      t.json :location


    end
    add_index  :lactic_locations, [:latitude, :longitude]

  end
end
