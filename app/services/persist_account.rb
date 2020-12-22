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
      if persisted_account.present?
        persisted_account.update(account_params)
        persisted_account
      else
        current_user.accounts.create(account_params)
      end
    end
  end

  private

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
