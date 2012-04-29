class CreateDesks < ActiveRecord::Migration
  def change
    create_table :desks do |t|
      t.string :name, limit: 32
      t.string :abrev, limit: 12
      t.references :user

      t.timestamps
    end
  end
end
