class AddRecipientIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recipient_id, :integer
    remove_column :users,  
  end

  def self.down:q

  end
end
