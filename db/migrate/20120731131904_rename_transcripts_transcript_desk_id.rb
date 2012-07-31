class RenameTranscriptsTranscriptDeskId < ActiveRecord::Migration
  def change
    rename_column :transcripts, :transcript_desk_id, :transcript_workstation_id
  end
end

