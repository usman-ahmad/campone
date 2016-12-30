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

ActiveRecord::Schema.define(version: 20161230065744) do

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
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.text     "description"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.integer  "project_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "uploader_id"
    t.string   "title"
    t.string   "type"
    t.index ["project_id"], name: "index_attachments_on_project_id", using: :btree
    t.index ["uploader_id"], name: "index_attachments_on_uploader_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "contributions", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "token"
    t.string   "status",     default: "pending"
    t.integer  "inviter_id"
    t.index ["inviter_id"], name: "index_contributions_on_inviter_id", using: :btree
    t.index ["project_id"], name: "index_contributions_on_project_id", using: :btree
    t.index ["user_id"], name: "index_contributions_on_user_id", using: :btree
  end

  create_table "discussions", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "private"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["project_id"], name: "index_discussions_on_project_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.date     "due_at"
    t.integer  "project_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["project_id"], name: "index_events_on_project_id", using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "integrations", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.string   "token"
    t.string   "secret"
    t.index ["project_id"], name: "index_integrations_on_project_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "is_deleted"
    t.index ["activity_id"], name: "index_notifications_on_activity_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "payloads", force: :cascade do |t|
    t.text     "info"
    t.integer  "integration_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "event"
    t.index ["integration_id"], name: "index_payloads_on_integration_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "owner_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "slug"
    t.integer  "current_ticket_id", default: 1
    t.index ["slug"], name: "index_projects_on_slug", unique: true, using: :btree
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "project_id"
    t.string   "priority",    default: "None"
    t.date     "due_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "state",       default: "unscheduled"
    t.integer  "owner_id"
    t.integer  "reporter_id"
    t.integer  "position"
    t.string   "ticket_id"
    t.index ["owner_id"], name: "index_tasks_on_owner_id", using: :btree
    t.index ["project_id"], name: "index_tasks_on_project_id", using: :btree
    t.index ["reporter_id"], name: "index_tasks_on_reporter_id", using: :btree
    t.index ["ticket_id"], name: "index_tasks_on_ticket_id", unique: true, using: :btree
  end

  create_table "user_discussions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.boolean  "notify"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["discussion_id"], name: "index_user_discussions_on_discussion_id", using: :btree
    t.index ["user_id"], name: "index_user_discussions_on_user_id", using: :btree
  end

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
    t.datetime "deleted_at"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "attachments", "projects"
  add_foreign_key "attachments", "users", column: "uploader_id"
  add_foreign_key "comments", "users"
  add_foreign_key "contributions", "projects"
  add_foreign_key "contributions", "users"
  add_foreign_key "contributions", "users", column: "inviter_id"
  add_foreign_key "discussions", "projects"
  add_foreign_key "events", "projects"
  add_foreign_key "identities", "users"
  add_foreign_key "integrations", "projects"
  add_foreign_key "notifications", "activities"
  add_foreign_key "notifications", "users"
  add_foreign_key "payloads", "integrations"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users", column: "reporter_id"
  add_foreign_key "user_discussions", "discussions"
  add_foreign_key "user_discussions", "users"
end
