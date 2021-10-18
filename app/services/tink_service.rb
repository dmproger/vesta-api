require_relative '../tink_api/v1/client'

class TinkService
  class << self
    def get_rental_payment(users, notification: true)
      for user in users
        last_associated_transaction_date = user.associated_transactions.maximum(:updated_at) || 1.year.ago

        grab_tink_transactions(user)
        match_transactions_with_properties(user)

        return unless notification

        new_matched_transactions =
          user.
            saved_transactions.
            joins(:associated_transaction).
            where('associated_transactions.updated_at > ?', last_associated_transaction_date)

        Notification.rental_payment!(user, new_matched_transactions)
      end
    end

    def grab_tink_transactions(user, account = nil)
      (account ? [account] : user.accounts).each do |account|
        transactions = get_tink_transactions(user, account)
        PersistTransaction.new(transactions, user, account).call if transactions.any?
      end
    end

    def get_tink_transactions(user, account = nil)
      (account ? [account] : user.accounts).each_with_object([]) do |account, result|
        result <<
          TinkAPI::V1::Client.new(user.valid_tink_token(scopes: 'transactions:read')).
            transactions(account_id: account.account_id, query_tag: '').
            dig(:results)
      end.flatten
    end

    def to_saved_transactions(transactions)
      User.new.saved_transactions.build(to_saved_transaction_hash(transactions))
    end

    def to_saved_transaction_attrs(transactions)
      [transactions].flatten.map do |transaction|
        transaction.symbolize_keys!
        hash = {}
        hash[:amount] = transaction.dig(:amount)
        hash[:category_id] = transaction.dig(:categoryId)
        hash[:category_type] = transaction.dig(:categoryType)
        hash[:transaction_date] = Time.at(transaction.dig(:date) / 1000).to_date
        hash[:description] = transaction.dig(:originalDescription)
        hash[:transaction_id] = transaction.dig(:id)
        hash[:notes] = transaction.dig(:notes)
        hash[:is_pending] = transaction.dig(:pending)
        hash[:is_modified] = transaction.dig(:userModified)
        hash
      end
    end

    def match_transactions_with_properties(user)
      AssociateTransactionsWithTenants.new(user.id).perform
    end

    def to_tink_time(time)
      (time.to_f * 1000).to_i
    end

    def to_time(tink_time)
      Time.at(tink_time / 1000).to_date
    end
  end
end
