class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :content
      t.integer :user_id
      t.integer :reciever
      t.integer :read
      t.datetime :time_read

      t.timestamps
    end
  end
end
