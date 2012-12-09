class RemoveWorkstationIdFromOutgoingReceipts < ActiveRecord::Migration
  def change
    remove_column :outgoing_receipts, :workstation_id
  end
end
