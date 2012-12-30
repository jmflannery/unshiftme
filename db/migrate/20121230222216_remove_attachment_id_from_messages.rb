class RemoveAttachmentIdFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :attachment_id
  end
end
