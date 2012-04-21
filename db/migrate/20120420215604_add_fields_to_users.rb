class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :middle_initial, :string, limit: 1
    add_column :users, :last_name, :string
    add_column :users, :login_name, :string

    remove_column :users, :name
    remove_column :users, :full_name
  end
end
