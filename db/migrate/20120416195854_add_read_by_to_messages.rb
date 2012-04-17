class AddReadByToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :read_by, :string
  end
end
