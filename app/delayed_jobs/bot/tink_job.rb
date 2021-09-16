require_relative '../../tink_api/v1/client'

MODELS = [Account, SavedTransaction]
require_relative '../../../spec/support/manual/test_user_data'

class Bot::TinkJob < Bot
  USERS = [USER]

  self.cron_expression = '*/1 * * * *'

  def perform
    for user in USERS
      matched_transaction_ids = user.associated_transactions.pluck(:id)

      grab_transactions_form_tink(user)
      match_transactions_with_properties(user)

      new_matched_transactions =
        user.
          associated_transactions.reload.
          where.not(id: matched_transaction_ids)

      Notification.rental_payment!(user, new_matched_transactions)
    end
  end

  private

  def grab_transactions_form_tink(user)
    user.accounts.each do |account|
      transactions =
        TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read')).
          transactions(account_id: account.account_id, query_tag: '').
          dig(:results)

      PersistTransaction.new(transactions, user, account).call if transactions.any?
    end
  end

  def match_transactions_with_properties(user)
    AssociateTransactionsWithTenants.new(user.id)
  end
end
