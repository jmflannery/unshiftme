class RemoveSentFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :sent
  end
end
