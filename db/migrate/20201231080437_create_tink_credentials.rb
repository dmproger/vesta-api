class CreateTinkCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :tink_credentials, id: :uuid do |t|
      t.string :username
      t.string :credentials_id
      t.string :provider_name
      t.datetime :status_expiry_date
      t.string :status
      t.string :status_payload
      t.datetime :status_updated
      t.string :supplemental_information
      t.string :credentials_type
      t.datetime :updated
      t.string :tink_user_id
      t.references :account, type: :uuid
      t.timestamps
    end
  end
end
