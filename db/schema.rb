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

ActiveRecord::Schema.define(version: 20140422122320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "phone"
    t.string   "website"
    t.string   "email"
  end

  create_table "plancategories", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plantypes", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.float    "vat"
    t.float    "minprice"
    t.integer  "plancategory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plantypes", ["plancategory_id"], name: "index_plantypes_on_plancategory_id", using: :btree

  create_table "project_customers", force: true do |t|
    t.integer  "project_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_customers", ["customer_id"], name: "index_project_customers_on_customer_id", using: :btree
  add_index "project_customers", ["project_id"], name: "index_project_customers_on_project_id", using: :btree

  create_table "project_files", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "content_type"
    t.integer  "created_by"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_files", ["project_id"], name: "index_project_files_on_project_id", using: :btree

  create_table "project_tasks", force: true do |t|
    t.string   "content"
    t.boolean  "completed"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_tasks", ["project_id"], name: "index_project_tasks_on_project_id", using: :btree

  create_table "project_users", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_users", ["project_id"], name: "index_project_users_on_project_id", using: :btree
  add_index "project_users", ["user_id"], name: "index_project_users_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.date     "startdate"
    t.date     "enddate"
    t.integer  "status"
    t.integer  "created_by"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["category_id"], name: "index_projects_on_category_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "phone"
    t.string   "website"
    t.string   "email"
  end

  create_table "tasks", force: true do |t|
    t.string   "content"
    t.boolean  "completed"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password_salt"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth_token"
    t.integer  "role_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "address"
    t.string   "phone"
    t.integer  "customer_id"
    t.integer  "supplier_id"
  end

end
