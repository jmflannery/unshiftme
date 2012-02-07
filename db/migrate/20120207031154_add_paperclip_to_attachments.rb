class AddPaperclipToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :attachment_file_name, :string

    add_column :attachments, :attachment_content_type, :string

    add_column :attachments, :attachment_file_size, :integer

    add_column :attachments, :attachment_updated_at, :datetime

    remove_column :attachments, :name

    remove_column :attachments, :content_type

    remove_column :attachments, :file
  end
end
