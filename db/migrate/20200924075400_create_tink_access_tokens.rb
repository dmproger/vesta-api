class CreateTinkAccessTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tink_access_tokens, id: :uuid do |t|
      t.string :token_type
      t.integer :expires_in
      t.text :access_token
      t.string :refresh_token
      t.string :scope
      t.string :id_hint
      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
