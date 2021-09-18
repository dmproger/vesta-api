class TinkService
  class << self
    def get_rental_payment(users, notification: true)
      for user in users
        last_associated_transaction_date = user.associated_transactions.max(:updated_at) || 1.year.ago

        grab_transactions_form_tink(user)
        match_transactions_with_properties(user)

        return unless notification

        new_matched_transactions =
          user.
            saved_transactions.
            joins(:associated_transactions).
            where('associated_transactions.updated_at > ?', last_associated_transaction_date)

        Notification.rental_payment!(user, new_matched_transactions)
      end
    end

    def grab_transactions_form_tink(user)
      user.accounts.each do |account|
        transactions = get_tink_transactions(user, account)
        PersistTransaction.new(transactions, user, account).call if transactions.any?
      end
    end

    def get_tink_transactions(user, account)
      TinkAPI::V1::Client.new(user.valid_tink_token(scopes: 'transactions:read')).
        transactions(account_id: account.account_id, query_tag: '').
        dig(:results)
    end

    def match_transactions_with_properties(user)
      AssociateTransactionsWithTenants.new(user.id)
    end
  end
end
