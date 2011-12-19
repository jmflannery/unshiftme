class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do |t|
      t.integer :user_id
      t.integer :recipient_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :recipients
  end
end
