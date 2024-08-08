class CreateDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :discounts do |t|
      t.string :name, null: false
      t.string :type
      t.datetime :enable_at
      t.boolean :apiece, null: false
      t.jsonb :settings, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :discounts, :name, unique: true
  end
end