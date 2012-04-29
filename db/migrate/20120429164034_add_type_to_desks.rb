class AddTypeToDesks < ActiveRecord::Migration
  def change
    add_column :desks, :type, :string, limit: 32
  end
end
