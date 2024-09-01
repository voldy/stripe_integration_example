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

ActiveRecord::Schema[7.2].define(version: 2024_08_31_193448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "stripe_events", force: :cascade do |t|
    t.string "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", null: false
    t.string "status", default: "pending", null: false
    t.datetime "processed_at"
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_stripe_events_on_event_id", unique: true
  end

  create_table "subscriptions", id: :string, force: :cascade do |t|
    t.string "customer_id", null: false
    t.string "status", null: false
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
  end
end
