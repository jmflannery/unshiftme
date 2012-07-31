class RenameRecipientsDeskId < ActiveRecord::Migration
  def change
    rename_column :recipients, :desk_id, :workstation_id
  end
end
