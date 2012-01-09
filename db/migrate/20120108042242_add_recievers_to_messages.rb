class AddRecieversToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :recievers, :string
    remove_column :messages, :reciever
  end
end
