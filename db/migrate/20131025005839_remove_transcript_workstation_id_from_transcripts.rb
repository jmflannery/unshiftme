class RemoveTranscriptWorkstationIdFromTranscripts < ActiveRecord::Migration
  def change
    remove_column :transcripts, :transcript_workstation_id
  end
end
