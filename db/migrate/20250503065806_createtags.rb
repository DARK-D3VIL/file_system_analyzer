class Createtags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :tag_name, null: false
      t.references :file_record, null: false, foreign_key: true
    end

    add_index :tags, [:tag_name, :file_record_id], unique: true
  end
end
