class Changeportnumber < ActiveRecord::Migration[6.1]
  def change
    change_column_default :ephemeral_users, :port, 22
  end
end
