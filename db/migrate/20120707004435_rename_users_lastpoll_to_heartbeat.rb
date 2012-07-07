class RenameUsersLastpollToHeartbeat < ActiveRecord::Migration
  def change
    rename_column :users, :lastpoll, :heartbeat
  end
end
