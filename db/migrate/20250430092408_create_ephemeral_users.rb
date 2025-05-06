class CreateEphemeralUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :ephemeral_users do |t|
      t.string  :username,          null: false
      t.string  :host,              null: false
      t.integer :port,              null: false, default: 21
      t.text    :encrypted_password, null: false
      t.timestamps
    end
  end
end
