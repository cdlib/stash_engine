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

ActiveRecord::Schema.define(version: 20160318035403) do

  create_table "stash_engine_file_uploads", force: :cascade do |t|
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.integer  "resource_id",         limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "temp_file_path",      limit: 65535
  end

  create_table "stash_engine_identifiers", force: :cascade do |t|
    t.string   "identifier",      limit: 255
    t.string   "identifier_type", limit: 255
    t.integer  "resource_id",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "stash_engine_image_uploads", force: :cascade do |t|
    t.string   "image_name",       limit: 255
    t.string   "image_type",       limit: 255
    t.integer  "image_size",       limit: 4
    t.integer  "resource_id",      limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "stash_engine_resource_states", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "resource_state", limit: 11
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "resource_id",    limit: 4
  end

  create_table "stash_engine_resources", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.integer  "current_resource_state_id", limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "geolocation",                         default: false
  end

  create_table "stash_engine_submission_logs", force: :cascade do |t|
    t.integer  "resource_id",      limit: 4
    t.text     "archive_response", limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "stash_engine_users", force: :cascade do |t|
    t.string   "first_name",  limit: 255
    t.string   "last_name",   limit: 255
    t.string   "email",       limit: 255
    t.string   "uid",         limit: 255
    t.string   "provider",    limit: 255
    t.string   "oauth_token", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "tenant_id",   limit: 255
    t.boolean  "orcid",                   default: false
  end

  add_index "stash_engine_users", ["tenant_id"], name: "index_stash_engine_users_on_tenant_id", using: :btree

end
