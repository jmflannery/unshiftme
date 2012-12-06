class CreateMessageRoutes < ActiveRecord::Migration
  def change
    create_table :message_routes do |t|
      t.integer :user_id
      t.integer :workstation_id

      t.timestamps
    end
  end
end
