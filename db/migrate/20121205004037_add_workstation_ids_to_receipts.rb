class AddWorkstationIdsToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :workstation_ids, :string
  end
end
