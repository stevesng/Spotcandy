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

ActiveRecord::Schema.define(:version => 20110409171408) do

  create_table "admins", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "encrypted_password",   :limit => 128,                :null => false
    t.string   "password_salt",                                      :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.integer  "uid"
    t.string   "access_token"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candies", :force => true do |t|
    t.string   "pid"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",           :default => 0,     :null => false
    t.integer  "venue_id"
    t.boolean  "is_candy",        :default => false
    t.boolean  "rejected",        :default => false
    t.integer  "flag_status",     :default => 0,     :null => false
    t.integer  "default_photo"
    t.boolean  "facebook_update", :default => false, :null => false
  end

  create_table "candies_users", :id => false, :force => true do |t|
    t.integer  "candy_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "candies_venues", :id => false, :force => true do |t|
    t.integer  "venue_id"
    t.integer  "candy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "venue_id"
    t.integer  "venuetype"
    t.boolean  "watched",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "candy_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_remote_url"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "candy_id"
    t.integer  "user_id"
    t.boolean  "recommended", :default => true, :null => false
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

  create_table "temps", :id => false, :force => true do |t|
    t.string "email"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                  :null => false
    t.string   "encrypted_password",   :limit => 128,                    :null => false
    t.string   "password_salt",                                          :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "notify_candy",                        :default => true,  :null => false
    t.boolean  "verified",                            :default => false, :null => false
    t.integer  "jump_limit",                          :default => 100,   :null => false
    t.string   "gender"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_venues", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "venuetype"
  end

  create_table "variables", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", :force => true do |t|
    t.string   "foursquare_id"
    t.text     "location"
    t.decimal  "lat",           :precision => 15, :scale => 10
    t.decimal  "lng",           :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "people_count"
    t.integer  "locked",                                        :default => 0, :null => false
    t.integer  "candy_count",                                   :default => 0, :null => false
  end

end
