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

ActiveRecord::Schema[8.0].define(version: 2025_03_16_023556) do
  create_table "conversations", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "user_id"
    t.string "username"
    t.text "user_message"
    t.text "assistant_message"
    t.json "context", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id", "created_at"], name: "index_conversations_on_chat_id_and_created_at"
    t.index ["chat_id"], name: "index_conversations_on_chat_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end
end
