class AddRecieversToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :recievers, :string

    add_column :attachments, :delivered, :string
  end
end
