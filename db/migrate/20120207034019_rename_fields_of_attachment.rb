class RenameFieldsOfAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :payload_file_name, :string

    add_column :attachments, :payload_content_type, :string

    add_column :attachments, :payload_file_size, :integer

    add_column :attachments, :payload_updated_at, :datetime 

    remove_column :attachments, :attachment_file_name

    remove_column :attachments, :attachment_content_type

    remove_column :attachments, :attachment_file_size

    remove_column :attachments, :attachment_updated_at
  end
end
