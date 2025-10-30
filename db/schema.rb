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

ActiveRecord::Schema[8.0].define(version: 2025_10_29_213109) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
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

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country", default: "USA"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "time_entry_id"
    t.integer "project_id"
    t.string "description", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.decimal "rate", precision: 10, scale: 2, null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["project_id"], name: "index_invoice_line_items_on_project_id"
    t.index ["time_entry_id"], name: "index_invoice_line_items_on_time_entry_id"
  end

  create_table "invoice_payments", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "payment_date", null: false
    t.string "payment_method"
    t.string "reference_number"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_payments_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "invoice_number", null: false
    t.integer "status", default: 0, null: false
    t.date "invoice_date", null: false
    t.date "due_date", null: false
    t.date "paid_date"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.text "payment_instructions"
    t.string "po_number"
    t.datetime "sent_at"
    t.string "sent_to_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "entity_type", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "business_name"
    t.string "tax_id"
    t.string "email", null: false
    t.string "phone"
    t.string "website"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country", default: "USA"
    t.string "invoice_prefix", default: "INV"
    t.integer "next_invoice_number", default: 1
    t.integer "default_payment_terms", default: 30
    t.text "default_invoice_notes"
    t.text "default_payment_instructions"
    t.string "primary_color", default: "#5cb85c"
    t.boolean "show_logo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "rate", precision: 10, scale: 2
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["name", "client_id"], name: "index_projects_on_name_and_client_id", unique: true
  end

  create_table "time_entries", force: :cascade do |t|
    t.string "task", null: false
    t.text "notes"
    t.integer "project_id", null: false
    t.integer "client_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "duration_seconds"
    t.decimal "rate", precision: 10, scale: 2
    t.decimal "earnings", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_time_entries_on_client_id"
    t.index ["project_id"], name: "index_time_entries_on_project_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoice_line_items", "projects"
  add_foreign_key "invoice_line_items", "time_entries"
  add_foreign_key "invoice_payments", "invoices"
  add_foreign_key "invoices", "clients"
  add_foreign_key "projects", "clients"
  add_foreign_key "time_entries", "clients"
  add_foreign_key "time_entries", "projects"
end
