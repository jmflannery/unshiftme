class RenameReadsToReceipts < ActiveRecord::Migration
  def up
    rename_table :reads, :receipts
  end

  def down
    rename_table :receipts, :reads
  end
end
