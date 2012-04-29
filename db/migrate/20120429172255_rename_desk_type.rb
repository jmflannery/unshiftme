class RenameDeskType < ActiveRecord::Migration
  def change
    rename_column :desks, :type, :job_type
  end
end
