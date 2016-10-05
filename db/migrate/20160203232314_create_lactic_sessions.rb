class CreateLacticSessions < ActiveRecord::Migration
  def change
    create_table :lactic_sessions do |t|
      t.string :title
      t.text :description
      t.datetime :start_date_time
      t.datetime :end_date_time
      t.string :location
      t.string :location_id
      t.integer :duration
      t.integer :week_day
      t.string :creator_fb_id
      t.boolean :shared

      t.timestamps null: false
    end
  end
end
