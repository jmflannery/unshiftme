class AddStatusToUsers < ActiveRecord::Migration
  def up
    add_column :users, :status, :boolean
  end

  def down
    remove_column :users, :status
  end
end
