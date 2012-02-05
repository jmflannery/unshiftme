class AddMetaDataToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :name, :string

    add_column :attachments, :content_type, :string

  end
end
