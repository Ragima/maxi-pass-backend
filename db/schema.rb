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

ActiveRecord::Schema.define(version: 2019_08_22_090123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.string "trackable_type"
    t.integer "trackable_id"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "team_name"
    t.string "actor_role"
    t.string "actor_email"
    t.string "actor_action"
    t.string "subj1_id"
    t.string "subj1_title"
    t.string "subj1_action"
    t.string "subj2_id"
    t.string "subj2_title"
    t.string "subj2_action"
    t.string "subj3_id"
    t.string "subj3_title"
    t.string "action_type"
    t.string "action_act"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["team_name"], name: "index_activities_on_team_name"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "vault_item_id"
    t.text "content"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "encrypted", default: true
    t.text "file_name"
    t.index ["vault_item_id"], name: "index_documents_on_vault_item_id"
  end

  create_table "group_admin_keys", force: :cascade do |t|
    t.uuid "group_id"
    t.integer "user_id"
    t.string "key"
    t.index ["group_id"], name: "index_group_admin_keys_on_group_id"
    t.index ["user_id"], name: "index_group_admin_keys_on_user_id"
  end

  create_table "group_hierarchies", id: false, force: :cascade do |t|
    t.uuid "ancestor_id", null: false
    t.uuid "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "group_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "group_desc_idx"
  end

  create_table "group_users", id: :serial, force: :cascade do |t|
    t.uuid "group_id"
    t.integer "user_id"
    t.text "group_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true
    t.index ["role"], name: "index_group_users_on_role"
  end

  create_table "group_vaults", id: :serial, force: :cascade do |t|
    t.uuid "group_id"
    t.uuid "vault_id"
    t.text "vault_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "vault_id"], name: "index_group_vaults_on_group_id_and_vault_id", unique: true
  end

  create_table "groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "admin_keys", default: {}
    t.string "team_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "parent_group_id"
    t.text "lead_keys"
    t.index ["name", "team_name"], name: "index_groups_on_name_and_team_name", unique: true
    t.index ["parent_group_id"], name: "index_groups_on_parent_group_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "done", default: false
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.string "password_salt"
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team_name"
    t.index ["team_name"], name: "index_services_on_team_name"
  end

  create_table "subscription_actions", force: :cascade do |t|
    t.string "entity_type"
    t.string "action_type"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "subscription_action_id"
    t.index ["subscription_action_id"], name: "index_subscriptions_on_subscription_action_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "teams", primary_key: "name", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "support_personal_vaults", default: false
    t.boolean "otp_required_for_login", default: false
    t.index "lower((name)::text)", name: "index_teams_on_lowercase_name", unique: true
  end

  create_table "user_vaults", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.uuid "vault_id"
    t.text "vault_key"
    t.boolean "vault_writer", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["role"], name: "index_user_vaults_on_role"
    t.index ["user_id", "vault_id"], name: "index_user_vaults_on_user_id_and_vault_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "role_id", default: 0
    t.string "temp"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "public_key"
    t.string "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team_name"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "phone_number"
    t.string "sms_code"
    t.string "authentication_type", default: "none"
    t.string "name"
    t.boolean "reset_pass", default: false
    t.boolean "change_pass", default: false
    t.string "recovery_token"
    t.boolean "patched", default: false
    t.boolean "support_personal_vaults", default: false
    t.string "uid", default: "", null: false
    t.string "provider", default: "email", null: false
    t.jsonb "tokens"
    t.boolean "extension_access", default: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "blocked", default: false
    t.datetime "password_changed_at"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "locale", default: "en", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email", "team_name"], name: "index_users_on_email_and_team_name", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vault_admin_keys", force: :cascade do |t|
    t.uuid "vault_id"
    t.integer "user_id"
    t.string "key"
    t.index ["user_id"], name: "index_vault_admin_keys_on_user_id"
    t.index ["vault_id"], name: "index_vault_admin_keys_on_vault_id"
  end

  create_table "vault_items", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.text "tags"
    t.uuid "vault_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "only_for_admins"
  end

  create_table "vaults", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.jsonb "admin_keys", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_shared", default: false
    t.string "team_name"
    t.integer "user_id"
  end

  add_foreign_key "activities", "teams", column: "team_name", primary_key: "name", name: "fk_activities_team", on_delete: :cascade
  add_foreign_key "group_admin_keys", "groups", on_delete: :cascade
  add_foreign_key "group_admin_keys", "users", on_delete: :cascade
  add_foreign_key "group_users", "groups", name: "fk_group_users__groups", on_delete: :cascade
  add_foreign_key "group_users", "users", name: "fk_group_users__users", on_delete: :cascade
  add_foreign_key "group_vaults", "groups", name: "fk_group_vaults__groups", on_delete: :cascade
  add_foreign_key "group_vaults", "vaults", name: "fk_group_vaults__vaults", on_delete: :cascade
  add_foreign_key "groups", "teams", column: "team_name", primary_key: "name", name: "fk_groups__teams", on_delete: :cascade
  add_foreign_key "subscriptions", "subscription_actions", on_delete: :cascade
  add_foreign_key "subscriptions", "users", on_delete: :cascade
  add_foreign_key "user_vaults", "users", name: "fk_user_vaults__users", on_delete: :cascade
  add_foreign_key "user_vaults", "vaults", name: "fk_user_vaults__vaults", on_delete: :cascade
  add_foreign_key "users", "teams", column: "team_name", primary_key: "name", name: "fk_users__teams", on_delete: :cascade
  add_foreign_key "vault_admin_keys", "users", on_delete: :cascade
  add_foreign_key "vault_admin_keys", "vaults", on_delete: :cascade
  add_foreign_key "vault_items", "vaults", name: "fk_vault_items__vaults", on_delete: :cascade
  add_foreign_key "vaults", "teams", column: "team_name", primary_key: "name", name: "fk_vaults__teams", on_delete: :cascade
  add_foreign_key "vaults", "users", name: "fk_vaults__users", on_delete: :cascade
end
