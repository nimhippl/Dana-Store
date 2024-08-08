class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :roles, :name, unique: true
  end
end
