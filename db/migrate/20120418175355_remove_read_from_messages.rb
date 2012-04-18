class RemoveReadFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :read, :time_read
  end
end
