class Updaterefrence < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :file_records, :groups
    add_foreign_key :file_records, :groups, on_delete: :nullify
  end
end
