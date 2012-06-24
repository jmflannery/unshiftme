class RenameUsersDesksToNormalDesks < ActiveRecord::Migration
  def change
    rename_column :users, :desks, :normal_desks
  end
end
