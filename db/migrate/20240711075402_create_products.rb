class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, null: false
      t.integer :quantity, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :products, :name, unique: true
  end
end
