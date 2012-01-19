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

ActiveRecord::Schema.define(:version => 0) do

  create_table "deliverables", :force => true do |t|
    t.integer  "timeentry_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "effortmutes", :force => true do |t|
    t.string   "email_id"
    t.string   "effort_id"
    t.boolean  "muted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "efforts", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "muted"
  end

  create_table "emails", :force => true do |t|
    t.string   "address"
    t.integer  "user_id"
    t.string   "verification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "verified"
  end

  create_table "participations", :force => true do |t|
    t.integer  "project_id"
    t.integer  "email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projectmutes", :force => true do |t|
    t.string  "email_id"
    t.string  "project_id"
    t.boolean "muted"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "email_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "muted"
  end

  create_table "taginfos", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.integer  "taginfo_id"
    t.integer  "effort_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timeentries", :force => true do |t|
    t.integer  "effort_id"
    t.integer  "email_id"
    t.integer  "minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_id"
    t.string   "location"
  end
end
