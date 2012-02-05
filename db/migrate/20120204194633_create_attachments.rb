class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.binary :file

      t.timestamps
    end
  end
end
