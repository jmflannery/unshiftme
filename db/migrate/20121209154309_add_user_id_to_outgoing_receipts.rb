class AddUserIdToOutgoingReceipts < ActiveRecord::Migration
  def change
    add_column :outgoing_receipts, :user_id, :integer
    add_column :outgoing_receipts, :workstations, :string
  end
end
