class Updategroupsforeignkey < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :groups, column: :original_file_id
    add_foreign_key :groups, :file_records, column: :original_file_id, on_delete: :cascade
  end
end
