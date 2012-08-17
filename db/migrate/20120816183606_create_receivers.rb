class CreateReceivers < ActiveRecord::Migration
  def change
    create_table :receivers do |t|
      t.integer :message_id
      t.integer :workstation_id
      t.integer :user_id

      t.timestamps
    end
  end
end
