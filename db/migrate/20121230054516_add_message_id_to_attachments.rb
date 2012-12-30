class AddMessageIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :message_id, :integer
  end
end
