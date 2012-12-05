class RenameRecipientsToMessageRoutes < ActiveRecord::Migration
  def change
    rename_table :recipients, :message_routes
  end
end
