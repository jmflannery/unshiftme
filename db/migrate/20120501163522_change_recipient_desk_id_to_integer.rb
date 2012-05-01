class ChangeRecipientDeskIdToInteger < ActiveRecord::Migration
  def up
    remove_column :recipients, :recipient_desk_id
    add_column :recipients, :desk_id, :integer
  end

  def down
    remove_column :recipients, :desk_id
    add_column :recipients, :recipient_desk_id, :string
  end
end
