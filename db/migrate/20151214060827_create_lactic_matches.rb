class CreateLacticMatches < ActiveRecord::Migration
  def change
    create_table :lactic_matches do |t|
      t.string :requestor
      t.string :responder
      t.string :status

      t.timestamps null: false
    end
  end
end
