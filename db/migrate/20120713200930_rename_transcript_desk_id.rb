class RenameTranscriptDeskId < ActiveRecord::Migration
  def change
    rename_column :transcripts, :transcript_desk, :transcript_desk_id
  end
end
