class AddIndexToFileUploadsUploadFilename < ActiveRecord::Migration
  def change
    add_index(:stash_engine_file_uploads, :upload_file_name)
    add_index(:stash_engine_file_uploads, :resource_id)
    add_index(:stash_engine_file_uploads, :file_state)
  end
end
