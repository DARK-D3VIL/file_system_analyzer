class Createfilerecords < ActiveRecord::Migration[6.1]
  def change
    create_table :file_records do |t|
      t.references :ephemeral_user, null: false, foreign_key: true
      t.string :file_name, null: false
      t.integer :file_size, null: false
      t.string :path, null: false
      t.boolean :is_duplicate, default: false
      t.boolean :is_anomalous, default: false
      t.boolean :is_archivable, default: false
      t.string :file_type, default: 'not_defined'
      t.datetime :created_at
      t.datetime :accessed_at
      t.datetime :modified_at
    end

    add_index :file_records, :path, unique: true
  end
end
