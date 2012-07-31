class RenameUsersNormalDesks < ActiveRecord::Migration
  def change
    rename_column :users, :normal_desks, :normal_workstations
  end
end

