class AddIndexToChats < ActiveRecord::Migration[5.0]
  def change
    add_index :chats, ["token", "number"], :unique => true
  end
end
