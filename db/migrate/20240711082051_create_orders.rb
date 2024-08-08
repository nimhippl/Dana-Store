class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :state, null: false
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :cancelable_until, null: false
    end
  end
end