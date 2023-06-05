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

ActiveRecord::Schema[7.0].define(version: 2023_06_04_062605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "odds", force: :cascade do |t|
    t.string "race_id"
    t.string "horse"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_odds_on_race_id"
  end

  create_table "predicts", force: :cascade do |t|
    t.string "orepro_predict_id"
    t.string "user_id"
    t.string "race_id"
    t.string "mark"
    t.string "horse"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_predicts_on_race_id"
    t.index ["user_id"], name: "index_predicts_on_user_id"
  end

  create_table "races", id: :string, force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "place"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "odds", "races"
  add_foreign_key "predicts", "races"
  add_foreign_key "predicts", "users"
end
