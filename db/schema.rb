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

ActiveRecord::Schema.define(:version => 20120207034019) do

  create_table "attachments", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "recievers"
    t.string   "delivered"
    t.string   "payload_file_name"
    t.string   "payload_content_type"
    t.integer  "payload_file_size"
    t.datetime "payload_updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "read"
    t.datetime "time_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recievers"
    t.string   "sent"
  end

  create_table "recipients", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipient_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.boolean  "status"
    t.integer  "recipient_id"
    t.datetime "lastpoll"
  end

end
