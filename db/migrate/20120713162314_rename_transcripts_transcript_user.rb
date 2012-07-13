class RenameTranscriptsTranscriptUser < ActiveRecord::Migration
  def change
    rename_column :transcripts, :watch_user_id, :transcript_user_id
  end
end
