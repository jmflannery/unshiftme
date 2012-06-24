class AddDesksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :desks, :string
  end
end
