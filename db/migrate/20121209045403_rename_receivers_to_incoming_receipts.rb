class RenameReceiversToIncomingReceipts < ActiveRecord::Migration
  def change
    rename_table :receivers, :incoming_receipts
  end
end
