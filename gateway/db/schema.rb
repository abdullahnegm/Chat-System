# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_16_133341) do
    create_table "applications", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
        t.string "name", null: false
        t.string "token", null: false
        t.integer "chats_count", default: 0
        t.index ["token"], name: "index_applications_on_token", unique: true
    end

    create_table "chats", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
        t.string "name", null: false
        t.integer "number", default: 0
        t.string "token", null: false
        t.string "messages_count", default: 0
        t.index ["token", "number"], name: "index_chats_on_token_and_number", unique: true
    end

    create_table "messages", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
        t.string "body"
        t.string "token"
        t.string "chat_number"
        t.string "number"
        t.index ["token", "chat_number", "number"], name: "index_messages_on_token_and_chat_number_and_number", unique: true
    end
end
