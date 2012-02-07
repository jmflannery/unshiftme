class AddAttachmentIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :attachment_id, :integer
  end
end
