# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_31_144244) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bank_id"
    t.string "account_number"
    t.decimal "balance"
    t.decimal "available_credit"
    t.string "credentials_id"
    t.string "account_id"
    t.string "name"
    t.string "account_type"
    t.text "icon_url"
    t.text "banner_url"
    t.string "holder_name"
    t.boolean "is_closed"
    t.string "currency_code"
    t.datetime "refreshed"
    t.string "institution_id"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.string "post_code"
    t.string "country"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "associated_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_tenant_id"
    t.uuid "saved_transaction_id"
    t.uuid "joint_tenant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["joint_tenant_id"], name: "index_associated_transactions_on_joint_tenant_id"
    t.index ["property_tenant_id"], name: "index_associated_transactions_on_property_tenant_id"
    t.index ["saved_transaction_id"], name: "index_associated_transactions_on_saved_transaction_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "expense_properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expense_id", null: false
    t.uuid "property_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "saved_transaction_id", null: false
    t.index ["property_id", "expense_id", "saved_transaction_id"], name: "uniq_cortage_by_property_expense_transaction"
  end

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "report_state", default: 1, null: false
    t.index ["user_id", "name"], name: "index_expenses_on_user_id_and_name", unique: true
  end

  create_table "gc_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "gc_event_id"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_gc_events_on_user_id"
  end

  create_table "joint_tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "price"
    t.integer "day_of_month"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.uuid "tenant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tenant_id"], name: "index_joint_tenants_on_tenant_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "reciver"
    t.string "topic"
    t.text "text"
    t.boolean "viewed"
    t.boolean "helpful"
    t.integer "grade"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "subject"
    t.string "title"
    t.string "text"
    t.boolean "viewed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "payment_id"
    t.date "charge_date"
    t.string "description"
    t.string "status"
    t.uuid "subscription_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subscription_id"], name: "index_payments_on_subscription_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.string "post_code"
    t.string "country"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_archived", default: false
    t.date "archived_at"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "property_tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id"
    t.uuid "tenant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id"], name: "index_property_tenants_on_property_id"
    t.index ["tenant_id"], name: "index_property_tenants_on_tenant_id"
  end

  create_table "saved_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount"
    t.string "category_id"
    t.string "category_type"
    t.date "transaction_date"
    t.string "description"
    t.string "transaction_id"
    t.text "notes"
    t.boolean "is_pending", default: false
    t.boolean "is_modified", default: false
    t.integer "user_defined_category"
    t.uuid "user_id"
    t.uuid "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_processed", default: false
    t.boolean "is_associated", default: false
    t.integer "association_type"
    t.integer "report_state"
    t.index ["account_id"], name: "index_saved_transactions_on_account_id"
    t.index ["user_defined_category"], name: "index_saved_transactions_on_user_defined_category"
    t.index ["user_id"], name: "index_saved_transactions_on_user_id"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "interval_unit"
    t.integer "day_of_month"
    t.decimal "amount"
    t.date "start_date"
    t.boolean "is_active", default: false
    t.string "external_sub_id"
    t.string "currency"
    t.string "month"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "price"
    t.string "payment_frequency", default: "monthly"
    t.date "start_date"
    t.date "end_date"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.boolean "is_active", default: true
    t.uuid "property_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "expiry_job_id"
    t.string "payee_type", default: "tenant"
    t.integer "day_of_month"
    t.string "agent_name"
    t.string "agent_email"
    t.boolean "is_archived", default: false
    t.date "archived_at"
    t.index ["property_id"], name: "index_tenants_on_property_id"
  end

  create_table "tink_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token_type"
    t.integer "expires_in"
    t.text "access_token"
    t.string "refresh_token"
    t.string "scope"
    t.string "id_hint"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_tink_access_tokens_on_user_id"
  end

  create_table "tink_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "credentials_id"
    t.string "provider_name"
    t.datetime "status_expiry_date"
    t.string "status"
    t.string "status_payload"
    t.datetime "status_updated"
    t.string "supplemental_information"
    t.string "credentials_type"
    t.datetime "updated"
    t.string "tink_user_id"
    t.uuid "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_tink_credentials_on_account_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider", default: "phone", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "surname"
    t.string "phone"
    t.string "email"
    t.boolean "phone_verified", default: false
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "otp_secret_key"
    t.text "apns_token"
    t.string "mandate"
    t.string "customer"
    t.string "locale"
    t.string "market"
    t.string "tink_user_id"
    t.string "tink_auth_code"
    t.boolean "reset_accounts", default: false
    t.boolean "reset_properties", default: false
    t.boolean "reset_tenants", default: false
    t.boolean "reset_transactions", default: false
    t.jsonb "notification"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
