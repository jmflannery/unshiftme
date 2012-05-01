class RenameDeskId < ActiveRecord::Migration
  def change
    rename_column :recipients, :desk_id, :recipient_desk_id
  end
end
