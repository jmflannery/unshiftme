class AddSentToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sent, :string
  end
end
