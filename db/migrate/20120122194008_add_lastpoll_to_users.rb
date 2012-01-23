class AddLastpollToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lastpoll, :datetime
  end
end
