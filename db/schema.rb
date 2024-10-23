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

ActiveRecord::Schema[7.0].define(version: 2024_10_23_101018) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "date"
    t.string "location"
    t.string "image"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "mpesas", force: :cascade do |t|
    t.string "phoneNumber"
    t.string "amount"
    t.string "checkoutRequestID"
    t.string "merchantRequestID"
    t.string "mpesaReceiptNumber"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.bigint "sales_id", null: false
    t.integer "phoneNumber"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "mpesas_id", default: 0
    t.string "promo_code"
    t.integer "quantity"
    t.index ["mpesas_id"], name: "index_orders_on_mpesas_id"
    t.index ["sales_id"], name: "index_orders_on_sales_id"
    t.index ["ticket_id"], name: "index_orders_on_ticket_id"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.string "code"
    t.decimal "discount"
    t.datetime "valid_until"
    t.boolean "used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "ticket_id", null: false
    t.decimal "revenue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_sales_on_event_id"
    t.index ["ticket_id"], name: "index_sales_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "event_id"
    t.decimal "price"
    t.string "ticket_type"
    t.string "name"
    t.time "start_time"
    t.time "end_time"
    t.integer "group_size"
    t.boolean "is_group_ticket"
    t.string "qr_code_data"
    t.boolean "used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_quantity"
    t.integer "total_tickets"
  end

  create_table "users", force: :cascade do |t|
    t.string "business_name"
    t.integer "phone_number"
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "users"
  add_foreign_key "orders", "sales", column: "sales_id"
  add_foreign_key "orders", "tickets"
  add_foreign_key "sales", "events"
  add_foreign_key "sales", "tickets"
end
