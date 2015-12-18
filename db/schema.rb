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

ActiveRecord::Schema.define(version: 20151218143517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.text     "description"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.integer  "project_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "attachment_group_id"
    t.integer  "user_id"
  end

  add_index "attachments", ["project_id"], name: "index_attachments_on_project_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contributions", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contributions", ["project_id"], name: "index_contributions_on_project_id", using: :btree
  add_index "contributions", ["user_id"], name: "index_contributions_on_user_id", using: :btree

  create_table "discussions", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "private"
    t.integer  "project_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "discussion_group_id"
    t.integer  "user_id"
  end

  add_index "discussions", ["discussion_group_id"], name: "index_discussions_on_discussion_group_id", using: :btree
  add_index "discussions", ["project_id"], name: "index_discussions_on_project_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.date     "due_at"
    t.integer  "project_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "events", ["project_id"], name: "index_events_on_project_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "groups", ["type"], name: "index_groups_on_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "notifications", ["activity_id"], name: "index_notifications_on_activity_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "owner_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "project_group_id"
  end

  add_index "projects", ["project_group_id"], name: "index_projects_on_project_group_id", using: :btree

  create_table "replays", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "project_id"
    t.integer  "priority"
    t.date     "due_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "task_group_id"
    t.integer  "progress",      default: 0
    t.integer  "assigned_to"
    t.integer  "user_id"
  end

  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id", using: :btree
  add_index "tasks", ["task_group_id"], name: "index_tasks_on_task_group_id", using: :btree

  create_table "user_discussions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.boolean  "notify"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "user_discussions", ["discussion_id"], name: "index_user_discussions_on_discussion_id", using: :btree
  add_index "user_discussions", ["user_id"], name: "index_user_discussions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.string   "name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "attachments", "projects"
  add_foreign_key "comments", "users"
  add_foreign_key "contributions", "projects"
  add_foreign_key "contributions", "users"
  add_foreign_key "discussions", "projects"
  add_foreign_key "events", "projects"
  add_foreign_key "notifications", "activities"
  add_foreign_key "notifications", "users"
  add_foreign_key "tasks", "projects"
  add_foreign_key "user_discussions", "discussions"
  add_foreign_key "user_discussions", "users"
end
