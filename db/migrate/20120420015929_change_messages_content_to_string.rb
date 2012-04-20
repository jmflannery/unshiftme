class ChangeMessagesContentToString < ActiveRecord::Migration
  def change
    change_column :messages, :content, :string, limit: 300
  end
end
