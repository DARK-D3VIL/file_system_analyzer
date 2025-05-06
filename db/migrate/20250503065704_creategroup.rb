class Creategroup < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :content_hash, null: false
      t.integer :saved_size, default: 0
      t.integer :total_files, default: 0
      t.references :original_file, foreign_key: { to_table: :file_records }
      t.string :group_type
    end

    add_index :groups, :content_hash, unique: true
  end
end
