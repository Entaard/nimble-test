# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_14_141105) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "result_items", force: :cascade do |t|
    t.bigint "search_metadata_id"
    t.text "live_html"
    t.text "cached_html"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["search_metadata_id"], name: "index_result_items_on_search_metadata_id"
  end

  create_table "search_metadata", force: :cascade do |t|
    t.string "keyword"
    t.bigint "user_id"
    t.integer "num_of_ads"
    t.integer "num_of_links"
    t.string "num_of_all_results"
    t.string "search_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["keyword", "user_id"], name: "index_search_metadata_on_keyword_and_user_id"
    t.index ["user_id"], name: "index_search_metadata_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["username"], name: "index_users_on_username"
  end

end
