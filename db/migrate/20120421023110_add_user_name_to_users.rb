class AddUserNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_name, :string

    remove_column :users, :login_name
    remove_column :users, :screen_name
  end
end
