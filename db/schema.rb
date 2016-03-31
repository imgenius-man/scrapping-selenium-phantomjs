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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160331075740) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "patients", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "dob"
    t.string   "patient_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "token"
    t.string   "site_to_scrap"
    t.string   "password"
    t.string   "username"
    t.text     "raw_html"
    t.text     "json"
    t.string   "record_available"
    t.string   "site_url"
  end

  create_table "service_types", :force => true do |t|
    t.string   "type_name"
    t.string   "type_code"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "status_id"
    t.boolean  "mapped_service"
  end

  create_table "statuses", :force => true do |t|
    t.string   "site_url"
    t.boolean  "status"
    t.datetime "date_checked"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "login_status",          :default => false
    t.boolean  "patient_search_status", :default => false
    t.boolean  "site_status",           :default => false
  end

end
