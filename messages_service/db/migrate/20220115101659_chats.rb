class Chats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats, id: false do |t|
      t.string :name, null: false
      t.integer :number, default: 0
      t.string :token, null: false
      t.string :messages_count, default: 0
    end
  end
end
