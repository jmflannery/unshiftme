class RemoveRecieversFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :recievers
  end
end
