# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141117231800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "recipes", force: true do |t|
    t.string   "name",                     null: false
    t.text     "ingredients", default: [],              array: true
    t.text     "directions",  default: [],              array: true
    t.text     "notes",       default: [],              array: true
    t.string   "image"
    t.text     "tags",        default: [],              array: true
    t.string   "prep_time"
    t.string   "cook_time"
    t.string   "amount"
    t.text     "source"
    t.string   "source_base"
    t.text     "nutrition",   default: [],              array: true
    t.string   "slug"
    t.integer  "slug_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipes", ["ingredients"], name: "index_recipes_on_ingredients", using: :btree
  add_index "recipes", ["name"], name: "index_recipes_on_name", using: :btree
  add_index "recipes", ["slug"], name: "index_recipes_on_slug", unique: true, using: :btree
  add_index "recipes", ["slug_id"], name: "index_recipes_on_slug_id", unique: true, using: :btree
  add_index "recipes", ["source"], name: "index_recipes_on_source", using: :btree
  add_index "recipes", ["tags"], name: "index_recipes_on_tags", using: :btree

end
