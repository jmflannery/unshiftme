class RemovePayloadFromAttachments < ActiveRecord::Migration
  def up
    remove_column :attachments, :payload_file_name
    remove_column :attachments, :payload_content_type
    remove_column :attachments, :payload_file_size
    remove_column :attachments, :payload_updated_at
  end

  def down
    add_column :attachments, :payload_file_name
    add_column :attachments, :payload_content_type
    add_column :attachments, :payload_file_size
    add_column :attachments, :payload_updated_at
  end
end
