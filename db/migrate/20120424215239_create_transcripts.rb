class CreateTranscripts < ActiveRecord::Migration
  def change
    create_table :transcripts do |t|
      t.integer :user_id
      t.integer :watch_user_id
      t.timestamp :start_time
      t.timestamp :end_time

      t.timestamps
    end
  end
end
