class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :telegram_chat_id, null: false
      t.string :telegram_username
      t.string :username
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :users, :telegram_chat_id, unique: true
  end
end
