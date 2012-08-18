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

ActiveRecord::Schema.define(:version => 20120818193238) do

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
    t.string   "content",       :limit => 300
    t.integer  "user_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "sent"
    t.integer  "attachment_id"
    t.string   "read_by"
  end

  create_table "receivers", :force => true do |t|
    t.integer  "message_id"
    t.integer  "workstation_id"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "recipients", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "workstation_id"
  end

  create_table "sender_workstations", :force => true do |t|
    t.integer  "message_id"
    t.integer  "workstation_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "transcripts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "transcript_user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "transcript_workstation_id"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "password_digest"
    t.boolean  "status"
    t.datetime "heartbeat"
    t.string   "user_name"
    t.boolean  "admin"
    t.string   "normal_workstations"
  end

  create_table "workstations", :force => true do |t|
    t.string   "name",       :limit => 32
    t.string   "abrev",      :limit => 12
    t.integer  "user_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "job_type",   :limit => 32
  end

end
