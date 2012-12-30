class RemoveRecieversFromAttachments < ActiveRecord::Migration
  def change
    remove_column :attachments, :recievers
  end
end
