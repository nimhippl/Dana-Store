class CreateUsersRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :users_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
