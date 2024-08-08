class CreateProductsDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :products_discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :discount, null: false, foreign_key: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end