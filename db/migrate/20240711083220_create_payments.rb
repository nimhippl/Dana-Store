class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.integer :state, null: false
      t.decimal :amount, null: false
      t.references :order, null: false, foreign_key: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
