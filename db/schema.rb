# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_23_130505) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "sitename"
    t.string "hostname"
    t.string "slug"
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "todo_id"
    t.integer "user_id"
    t.string "texte"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "audience"
    t.index ["todo_id"], name: "index_comments_on_todo_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "fields", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "table_id"
    t.integer "datatype", default: 0
    t.string "items"
  end

  create_table "logs", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "todolist_id"
    t.integer "user_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "action_id"
    t.integer "account_id"
    t.index ["account_id"], name: "index_logs_on_account_id"
    t.index ["project_id"], name: "index_logs_on_project_id"
    t.index ["todolist_id"], name: "index_logs_on_todolist_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "mail_logs", force: :cascade do |t|
    t.string "to"
    t.string "subject"
    t.string "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_mail_logs_on_account_id"
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "want_notification", default: false
    t.boolean "want_dailynewsletter", default: true
    t.boolean "want_weeklynewsletter", default: true
    t.boolean "client"
    t.string "slug"
    t.index ["project_id"], name: "index_participants_on_project_id"
    t.index ["slug"], name: "index_participants_on_slug", unique: true
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description"
    t.date "duedate"
    t.integer "account_id"
    t.integer "workflow", default: 0
    t.text "memo"
    t.string "color"
    t.integer "table_id"
    t.string "slug"
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "tables", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "record_index", default: 0
    t.integer "account_id"
    t.string "slug"
    t.index ["slug"], name: "index_tables_on_slug", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "project"
    t.text "participants"
    t.text "todolists"
    t.text "todos"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "account_id"
    t.index ["account_id"], name: "index_templates_on_account_id"
  end

  create_table "todolists", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "row"
    t.date "duedate"
    t.string "slug"
    t.index ["project_id"], name: "index_todolists_on_project_id"
    t.index ["slug"], name: "index_todolists_on_slug", unique: true
  end

  create_table "todos", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.boolean "done"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "notify"
    t.date "duedate"
    t.integer "todolist_id"
    t.string "docfilename"
    t.string "docname"
    t.integer "notifydays", default: 1
    t.string "slug"
    t.decimal "charge_est", precision: 7, scale: 2, default: "0.0"
    t.decimal "charge_reelle", precision: 7, scale: 2, default: "0.0"
    t.index ["slug"], name: "index_todos_on_slug", unique: true
    t.index ["todolist_id"], name: "index_todos_on_todolist_id"
    t.index ["user_id"], name: "index_todos_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "picturelink"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "account_id"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer "role", default: 0, null: false
    t.string "slug"
    t.string "uid"
    t.string "provider"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "theme"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "values", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.string "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "table_id"
    t.integer "record_index"
    t.integer "todo_id"
    t.integer "user_id"
    t.index ["field_id"], name: "index_values_on_field_id"
    t.index ["record_index"], name: "index_values_on_record_index"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "mail_logs", "accounts"
end
