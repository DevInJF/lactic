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

ActiveRecord::Schema.define(version: 20160815091151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts_retrieves", force: :cascade do |t|
    t.boolean "lactic_contacts"
    t.string  "uid"
    t.json    "last_fetch",         default: [], array: true
    t.json    "hashed_fb_contacts", default: [], array: true
  end

  add_index "contacts_retrieves", ["uid"], name: "index_contacts_retrieves_on_uid", using: :btree

  create_table "engine_searches", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "keyword"
    t.json     "users",      default: [], array: true
  end

  add_index "engine_searches", ["keyword"], name: "index_engine_searches_on_keyword", using: :btree

  create_table "facebooks", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "uid"
    t.string   "osm_id"
    t.string   "access_token"
    t.datetime "access_token_expiration_date"
  end

  create_table "homes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lactic_locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "location"
  end

  add_index "lactic_locations", ["latitude", "longitude"], name: "index_lactic_locations_on_latitude_and_longitude", using: :btree

  create_table "lactic_matches", force: :cascade do |t|
    t.string   "requestor"
    t.string   "responder"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
  end

  create_table "lactic_sessions", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date_time"
    t.datetime "end_date_time"
    t.string   "location"
    t.string   "location_id"
    t.integer  "duration"
    t.integer  "week_day"
    t.string   "creator_fb_id"
    t.boolean  "shared"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "creator_id"
    t.boolean  "deleted"
    t.datetime "date_deleted"
    t.string   "location_origin"
    t.integer  "type",            default: 0
  end

  add_index "lactic_sessions", ["creator_fb_id"], name: "index_lactic_sessions_on_creator_fb_id", using: :btree
  add_index "lactic_sessions", ["creator_id"], name: "index_lactic_sessions_on_creator_id", using: :btree

  create_table "notifications", id: false, force: :cascade do |t|
    t.integer  "id",         limit: 8, default: "nextval('notifications_id_seq'::regclass)", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "requests",             default: 0
    t.integer  "invites",              default: 0
    t.integer  "timeline",             default: 0
    t.integer  "users",                default: 0
    t.json     "queue",                default: [],                                                       array: true
    t.datetime "month_date"
  end

  add_index "notifications", ["id", "month_date"], name: "index_notifications_on_id_and_month_date", unique: true, using: :btree

  create_table "osm_sessions", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "start_date_time"
    t.datetime "end_date_time"
    t.string   "title",                        null: false
    t.string   "uid"
    t.text     "description"
    t.string   "location"
    t.string   "location_id"
    t.string   "osm_id"
    t.boolean  "shared"
    t.string   "user_vote",       default: [],              array: true
    t.string   "creator_id"
    t.integer  "duration"
    t.integer  "week_day"
  end

  create_table "osm_subscribers", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "follower_id"
    t.string   "followee_id"
    t.string   "followee_uid"
    t.string   "follower_uid"
  end

  create_table "osm_user_infos", force: :cascade do |t|
    t.string   "title"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "osm_id"
  end

  create_table "session_replicas", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.json     "comments",   default: [],              array: true
    t.json     "info"
    t.integer  "origin_id"
    t.json     "votes",      default: [],              array: true
    t.json     "invitees",   default: [],              array: true
  end

  add_index "session_replicas", ["origin_id"], name: "index_session_replicas_on_origin_id", using: :btree

  create_table "sessions_retrieves", force: :cascade do |t|
    t.json     "last_fetch",        default: [], array: true
    t.json     "last_hashed_fetch", default: [], array: true
    t.string   "uid"
    t.boolean  "contact_sessions"
    t.datetime "month_date"
    t.text     "deleted_sessions",  default: [], array: true
  end

  add_index "sessions_retrieves", ["month_date"], name: "index_sessions_retrieves_on_month_date", using: :btree
  add_index "sessions_retrieves", ["uid"], name: "index_sessions_retrieves_on_uid", using: :btree

  create_table "user_info", id: :bigserial, force: :cascade do |t|
    t.string   "title"
    t.json     "locations",  default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "about"
  end

  create_table "user_infos", id: :bigserial, force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.json     "location"
    t.string   "location_id"
    t.text     "about",          default: [], array: true
    t.integer  "picture"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "public_service"
    t.json     "keywords_rated"
  end

  add_index "user_infos", ["latitude", "longitude"], name: "index_user_infos_on_latitude_and_longitude", using: :btree

  create_table "users", id: :bigserial, force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "uid"
    t.string   "name"
    t.string   "access_token"
    t.datetime "access_token_expiration_date"
    t.string   "email"
    t.text     "picture"
    t.string   "user_info"
    t.boolean  "matched"
    t.string   "matched_user"
    t.boolean  "email_confirmed"
    t.string   "confirm_token"
    t.string   "password"
    t.string   "avatar"
    t.string   "google_token"
    t.string   "google_id"
  end

end
