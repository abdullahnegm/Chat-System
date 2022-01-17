class CreateMessagesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :body
      t.string :token
      t.string :chat_number
      t.string :number

      t.index [:token, :chat_number, :number], unique: true
    end
  end
end
