class AddDepositToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :deposit, :decimal, default: 0.0, null: false
  end
end
