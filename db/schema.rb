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
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "dob"
    t.string   "patient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "site_to_scrap"
    t.string   "password"
    t.string   "username"
    t.text     "raw_html"
    t.text     "json"
    t.string   "record_available"
    t.string   "site_url"
    t.string   "state_field"
    t.string   "practice_name"
    t.string   "payer_name"
    t.string   "provider_name"
    t.string   "provider_type"
    t.string   "place_of_service"
    t.string   "service_type"
    t.string   "request_id"
    t.string   "response_id"
    t.datetime "response_datetime"
    t.datetime "request_datetime"
    t.string   "website"
    t.string   "request_status"
  end

  create_table "service_types", force: :cascade do |t|
    t.string   "type_name"
    t.string   "type_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.boolean  "mapped_service"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "site_url"
    t.datetime "date_checked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site_username"
    t.string   "site_password"
    t.text     "test_status_hash"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
