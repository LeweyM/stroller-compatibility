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

ActiveRecord::Schema[7.1].define(version: 2024_08_16_133938) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adapters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
  end

  create_table "compatible_links", force: :cascade do |t|
    t.bigint "product_a_id", null: false
    t.bigint "product_b_id", null: false
    t.bigint "adapter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adapter_id"], name: "index_compatible_links_on_adapter_id"
    t.index ["product_a_id"], name: "index_compatible_links_on_product_a_id"
    t.index ["product_b_id"], name: "index_compatible_links_on_product_b_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "url", null: false
    t.string "alt_text"
    t.string "attribution_url"
    t.string "attribution_text"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "productable_type", null: false
    t.bigint "productable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "brand_id", null: false
    t.string "slug"
    t.string "url"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["name"], name: "index_products_on_name", unique: true
    t.index ["productable_type", "productable_id"], name: "index_products_on_productable"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "strollers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "compatible_links", "products", column: "adapter_id", on_delete: :cascade
  add_foreign_key "compatible_links", "products", column: "product_a_id", on_delete: :cascade
  add_foreign_key "compatible_links", "products", column: "product_b_id", on_delete: :cascade
  add_foreign_key "images", "products"
  add_foreign_key "products", "brands"
end
