class AddTranscriptDeskToTranscripts < ActiveRecord::Migration
  def change
    add_column :transcripts, :transcript_desk, :integer
  end
end
