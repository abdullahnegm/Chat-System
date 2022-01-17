class CreateApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :applications, id: false, :primary_key => 'token' do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.integer :chats_count, default: 1

      t.index :token, unique: true
    end
  end
end
