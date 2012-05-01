class ChangeRecipientDeskIdToString < ActiveRecord::Migration
  def up
    change_column :recipients, :recipient_desk_id, :string
  end

  def down
    change_column :recipients, :recipient_desk_id, :integer
  end
end
