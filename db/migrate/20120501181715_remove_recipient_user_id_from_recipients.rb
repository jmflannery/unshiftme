class RemoveRecipientUserIdFromRecipients < ActiveRecord::Migration
  def change
    remove_column :recipients, :recipient_user_id
  end
end
