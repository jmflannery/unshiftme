class RemoveRecipientIdsFromAttachments < ActiveRecord::Migration
  def change
    remove_column :attachments, :recipient_id 
  end
end
