class RenameDesks < ActiveRecord::Migration
  def change
    rename_table :desks, :workstations
  end
end
