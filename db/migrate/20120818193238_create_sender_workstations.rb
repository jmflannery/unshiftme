class CreateSenderWorkstations < ActiveRecord::Migration
  def change
    create_table :sender_workstations do |t|
      t.integer :message_id
      t.integer :workstation_id

      t.timestamps
    end
  end
end
