class PersistTransaction
  attr_reader :transactions, :current_user, :account

  def initialize(transactions, current_user, account)
    @transactions = transactions
    @current_user = current_user
    @account = account
  end

  def call
    transactions.each do |transaction|
      transaction = transaction.symbolize_keys
      transaction_params = to_map_able_json(transaction.dig(:transaction).symbolize_keys)
      persisted_transaction = account.saved_transactions.find_by(transaction_id: transaction_params[:transaction_id])
      if persisted_transaction.present?
        persisted_transaction.update(transaction_params)
      else
        account.saved_transactions.create(transaction_params.merge!(user_id: current_user.id))
      end
    end
  end

  private

  def to_map_able_json(transaction)
    hash = {}
    hash[:amount] = transaction.dig(:amount)
    hash[:category_id] = transaction.dig(:categoryId)
    hash[:category_type] = transaction.dig(:categoryType)
    hash[:transaction_date] = Time.at(transaction.dig(:date) / 1000).to_date
    hash[:description] = transaction.dig(:description)
    hash[:transaction_id] = transaction.dig(:id)
    hash[:notes] = transaction.dig(:notes)
    hash[:is_pending] = transaction.dig(:pending)
    hash[:is_modified] = transaction.dig(:userModified)
    hash
  end
end
