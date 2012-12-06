class RecreateMessageRoutesTable < ActiveRecord::Migration
  def change
    drop_table :message_routes
  end
end
