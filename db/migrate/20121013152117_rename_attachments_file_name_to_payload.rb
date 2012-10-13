class RenameAttachmentsFileNameToPayload < ActiveRecord::Migration
  def up
    rename_column :attachments, :file_name, :payload
  end

  def down
    rename_column :attachments, :payload, :file_name
  end
end
