class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :bank_id
      t.string :account_number
      t.decimal :balance
      t.decimal :available_credit
      t.string :credentials_id
      t.string :account_id
      t.string :name
      t.string :account_type
      t.text :icon_url
      t.text :banner_url
      t.string :holder_name
      t.boolean :is_closed
      t.string :currency_code
      t.datetime :refreshed
      t.string :institution_id

      t.references :user, type: :uuid
      t.timestamps
    end
  end

  # {
  #
  #     "name": "Savings Account tink",
  #     "ownership": 1.0,
  #     "payload": null,
  #     "type": "SAVINGS",
  #     "userId": "d4c7f08800ee4d19a1ca754a347b8316",
  #     "userModifiedExcluded": false,
  #     "userModifiedName": false,
  #     "userModifiedType": false,
  #     "identifiers": "[\"se://1078646804708704?name=testAccount\"]",
  #     "transferDestinations": null,
  #     "details": null,
  #     "images": {
  #         "icon": "https://cdn.tink.se/provider-images/placeholder.png",
  #         "banner": null
  #     },
  #     "holderName": null,
  #     "closed": false,
  #     "flags": "[]",
  #     "accountExclusion": "NONE",
  #     "currencyCode": "SEK",
  #     "currencyDenominatedBalance": {
  #         "unscaledValue": 4708704,
  #         "scale": 2,
  #         "currencyCode": "SEK"
  #     },
  #     "refreshed": 1603094884000,
  #     "financialInstitutionId": "f58e31ebaf625c15a9601aa4deac83d0"
  # }
end
