class AddAttachmentIdToOutgoingReceipts < ActiveRecord::Migration
  def change
    add_column :outgoing_receipts, :attachment_id, :integer
  end
end
