class UpdateAuthorizationSystem < ActiveRecord::Migration
  def up
    remove_column :users, :salt
    remove_column :users, :encrypted_password
    add_column :users, :password_digest, :string
  end

  def down
    add_column :users, :salt, :string
    add_column :users, :encrypted_password, :string
    remove_column :users, :password_digest
  end
end
