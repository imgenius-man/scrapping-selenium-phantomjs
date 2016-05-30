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

ActiveRecord::Schema.define(version: 20160530073221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "dob",               limit: 255
    t.string   "patient_id",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "token",             limit: 255
    t.string   "site_to_scrap",     limit: 255
    t.string   "password",          limit: 255
    t.string   "username",          limit: 255
    t.text     "raw_html"
    t.text     "json"
    t.string   "record_available",  limit: 255
    t.string   "site_url",          limit: 255
    t.string   "state_field",       limit: 255
    t.string   "practice_name",     limit: 255
    t.string   "payer_name",        limit: 255
    t.string   "provider_name",     limit: 255
    t.string   "provider_type",     limit: 255
    t.string   "place_of_service",  limit: 255
    t.string   "service_type",      limit: 255
    t.string   "request_id"
    t.string   "response_id"
    t.datetime "response_datetime"
    t.datetime "request_datetime"
    t.string   "website"
    t.string   "request_status"
  end

  create_table "service_types", force: :cascade do |t|
    t.string   "type_name",      limit: 255
    t.string   "type_code",      limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "status_id"
    t.boolean  "mapped_service"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "site_url",         limit: 255
    t.datetime "date_checked"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "site_username",    limit: 255
    t.string   "site_password",    limit: 255
    t.text     "test_status_hash"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255, default: "", null: false
    t.string   "encrypted_password",  limit: 255, default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
