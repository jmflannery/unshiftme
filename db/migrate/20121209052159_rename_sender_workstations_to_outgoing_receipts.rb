class RenameSenderWorkstationsToOutgoingReceipts < ActiveRecord::Migration
  def change
    rename_table :sender_workstations, :outgoing_receipts
  end
end
