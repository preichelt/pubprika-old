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

ActiveRecord::Schema.define(version: 20150301083428) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "friendly_id_slugs", force: :cascade do |t|
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

  create_table "recipe_tags", force: :cascade do |t|
    t.integer  "recipe_id",  null: false
    t.integer  "tag_id",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "recipe_tags", ["recipe_id"], name: "index_recipe_tags_on_recipe_id", using: :btree
  add_index "recipe_tags", ["tag_id"], name: "index_recipe_tags_on_tag_id", using: :btree

  create_table "recipes", force: :cascade do |t|
    t.string   "name",                               null: false
    t.text     "ingredients",        default: [],                 array: true
    t.text     "directions",         default: [],                 array: true
    t.text     "notes",              default: [],                 array: true
    t.string   "image"
    t.string   "prep_time"
    t.string   "cook_time"
    t.string   "amount"
    t.text     "source"
    t.string   "source_base"
    t.text     "nutrition",          default: [],                 array: true
    t.string   "slug"
    t.integer  "slug_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "common_source_base", default: false
  end

  add_index "recipes", ["ingredients"], name: "index_recipes_on_ingredients", using: :btree
  add_index "recipes", ["name"], name: "index_recipes_on_name", using: :btree
  add_index "recipes", ["slug"], name: "index_recipes_on_slug", unique: true, using: :btree
  add_index "recipes", ["slug_id"], name: "index_recipes_on_slug_id", unique: true, using: :btree
  add_index "recipes", ["source"], name: "index_recipes_on_source", using: :btree
  add_index "recipes", ["source_base"], name: "index_recipes_on_source_base", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "singularized", null: false
    t.integer  "referenced",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
