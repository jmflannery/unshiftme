class RenameReceiptsToAcknowledgements < ActiveRecord::Migration
  def change
    rename_table :receipts, :acknowledgements
  end
end
