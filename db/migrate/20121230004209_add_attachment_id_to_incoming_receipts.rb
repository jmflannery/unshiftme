class AddAttachmentIdToIncomingReceipts < ActiveRecord::Migration
  def change
    add_column :incoming_receipts, :attachment_id, :integer
  end
end
