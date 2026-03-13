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

ActiveRecord::Schema[8.1].define(version: 2025_03_11_100001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "coupon_products", force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id", "product_id"], name: "index_coupon_products_on_coupon_id_and_product_id", unique: true
    t.index ["coupon_id"], name: "index_coupon_products_on_coupon_id"
    t.index ["product_id"], name: "index_coupon_products_on_product_id"
  end

  create_table "coupon_usages", force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.datetime "created_at", null: false
    t.integer "discount_amount", default: 0, null: false
    t.bigint "order_id"
    t.datetime "updated_at", null: false
    t.datetime "used_at", null: false
    t.bigint "user_id"
    t.index ["coupon_id"], name: "index_coupon_usages_on_coupon_id"
    t.index ["order_id"], name: "index_coupon_usages_on_order_id"
    t.index ["user_id"], name: "index_coupon_usages_on_user_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "discount_type", default: "percentage", null: false
    t.integer "discount_value", default: 0, null: false
    t.date "expiry_date"
    t.integer "max_discount"
    t.integer "min_cart_value", default: 0, null: false
    t.integer "per_user_limit"
    t.date "start_date"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_limit"
    t.index ["code"], name: "index_coupons_on_code", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "gift_card_transactions", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "gift_card_id", null: false
    t.bigint "order_id"
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_card_id"], name: "index_gift_card_transactions_on_gift_card_id"
    t.index ["order_id"], name: "index_gift_card_transactions_on_order_id"
  end

  create_table "gift_cards", force: :cascade do |t|
    t.integer "balance", default: 0, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expiry_date"
    t.integer "initial_balance", default: 0, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_gift_cards_on_code", unique: true
  end

  create_table "order_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_free_gift", default: false, null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["product_id"], name: "index_order_line_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "coupon_discount", default: 0, null: false
    t.bigint "coupon_id"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.integer "final_amount", default: 0, null: false
    t.integer "gift_card_discount", default: 0, null: false
    t.bigint "gift_card_id"
    t.string "shipping_address_line1"
    t.string "shipping_address_line2"
    t.string "shipping_city"
    t.string "shipping_country"
    t.string "shipping_postal_code"
    t.string "shipping_state"
    t.string "status", default: "pending"
    t.integer "total_amount", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["gift_card_id"], name: "index_orders_on_gift_card_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "product_combo_free_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_combo_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["product_combo_id", "product_id"], name: "index_product_combo_free_products_on_combo_and_product", unique: true
    t.index ["product_combo_id"], name: "index_product_combo_free_products_on_product_combo_id"
    t.index ["product_id"], name: "index_product_combo_free_products_on_product_id"
  end

  create_table "product_combo_triggers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_combo_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["product_combo_id", "product_id"], name: "index_product_combo_triggers_on_combo_and_product", unique: true
    t.index ["product_combo_id"], name: "index_product_combo_triggers_on_product_combo_id"
    t.index ["product_id"], name: "index_product_combo_triggers_on_product_id"
  end

  create_table "product_combos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "updated_at", null: false
    t.date "valid_from"
    t.date "valid_to"
    t.index ["is_active"], name: "index_product_combos_on_is_active"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "price", default: 0
    t.string "slug", null: false
    t.string "status", default: "draft"
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", unique: true
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "coupon_products", "coupons"
  add_foreign_key "coupon_products", "products"
  add_foreign_key "coupon_usages", "coupons"
  add_foreign_key "coupon_usages", "orders"
  add_foreign_key "coupon_usages", "users"
  add_foreign_key "gift_card_transactions", "gift_cards"
  add_foreign_key "gift_card_transactions", "orders"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "products"
  add_foreign_key "orders", "coupons"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "gift_cards"
  add_foreign_key "orders", "users"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "product_combo_free_products", "product_combos"
  add_foreign_key "product_combo_free_products", "products"
  add_foreign_key "product_combo_triggers", "product_combos"
  add_foreign_key "product_combo_triggers", "products"
end
