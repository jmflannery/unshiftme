class AddDeskIdToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :desk_id, :integer
  end
end
