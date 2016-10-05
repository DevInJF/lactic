class CreateSessionReplicas < ActiveRecord::Migration
  def change
    create_table :session_replicas do |t|

      t.datetime :start_date

      t.timestamps null: false
    end
  end
end
