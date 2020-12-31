class PersistAccount
  attr_reader :accounts, :current_user

  def initialize(accounts, current_user)
    @accounts = accounts
    @current_user = current_user
  end

  def call
    accounts.map do |account|
      account_params = to_map_able_json(account.symbolize_keys)
      persisted_account = current_user.accounts.find_by(account_id: account_params[:account_id])
      account = if persisted_account.present?
                  persisted_account.update(account_params)
                  persisted_account
                else
                  current_user.accounts.create(account_params)
                end
      persist_account_credentials(account)
      account
    end
  end

  private

  def persist_account_credentials(account)
    if account.tink_credential.present?
      if account.tink_credential&.updated_at < 1.hour.ago || account.credentials_expired?
        credential = get_updated_credential(account)
        account.tink_credential.update(credential.merge(updated_at: DateTime.current))
      end
    else
      credential = get_updated_credential(account)
      account.create_tink_credential(credential)
    end
  end

  def get_updated_credential(account)
    TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'credentials:read'))
                       .get_credentials(id: account.credentials_id)
  end

  def to_map_able_json(account)
    hash = {}
    hash[:bank_id] = account.dig(:bankId)
    hash[:account_number] = account.dig(:accountNumber)
    hash[:balance] = account.dig(:balance)
    hash[:available_credit] = account.dig(:availableCredit)
    hash[:credentials_id] = account.dig(:credentialsId)
    hash[:account_id] = account.dig(:id)
    hash[:name] = account.dig(:name)
    hash[:account_type] = account.dig(:type)
    hash[:icon_url] = account.dig(:images, 'icon')
    hash[:banner_url] = account.dig(:images, 'banner')
    hash[:holder_name] = account.dig(:holderName)
    hash[:is_closed] = account.dig(:closed)
    hash[:currency_code] = account.dig(:currencyCode)
    hash[:refreshed] = DateTime.strptime(account.dig(:refreshed).to_s,'%S') if account.dig(:refreshed).present?
    hash[:institution_id] = account.dig(:financialInstitutionId)
    hash
  end
end
