class AddUniqueIndexToFileRecords < ActiveRecord::Migration[6.1]
  def change
    remove_index :file_records, column: :path
    add_index :file_records, [:ephemeral_user_id, :path], unique: true
    add_index :file_records, :path
  end
end
