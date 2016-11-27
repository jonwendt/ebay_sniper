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

ActiveRecord::Schema.define(version: 20120816024112) do

  create_table "auctions", force: :cascade do |t|
    t.string   "item_id",           limit: 255
    t.integer  "user_id",           limit: 4
    t.integer  "max_bid",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "item",              limit: 65535
    t.text     "picture",           limit: 65535
    t.string   "auction_status",    limit: 255
    t.string   "user_notification", limit: 255,   default: "Do not notify"
    t.integer  "lead_time",         limit: 4,     default: 0
    t.string   "been_notified",     limit: 255
    t.string   "job_id",            limit: 255
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",                    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",                    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_number",           limit: 255
    t.text     "auth_token",             limit: 65535,                                 null: false
    t.datetime "auth_token_exp",                       default: '2016-11-27 21:28:47', null: false
    t.string   "username",               limit: 255
    t.string   "session_id",             limit: 255
    t.string   "preferred_status",       limit: 255,   default: "All"
    t.string   "preferred_sort",         limit: 255,   default: "title_asc"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
