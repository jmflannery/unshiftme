class RemoveFieldsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :first_name
    remove_column :users, :middle_initial
    remove_column :users, :last_name
  end

  def down
    add_column :users, :first_name, :string
    add_column :users, :middle_initial, :string, limit: 1
    add_column :users, :last_name, :string
  end
end
