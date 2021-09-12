require_relative '../../tink_api/v1/client'

class Bot::TinkMailer < ApplicationMailer
  default from: 'notifier@vesta_app.com'

  def income_transactions
    user = params[:user]
    service = TinkAPI::V1::Client.new(user.valid_tink_token(scopes: 'transactions:read'))

    @transactions = []

    for account in user.accounts
      transactions = account.saved_transactions.income
      tink_transactions =
        service.
          transactions(account_id: account.account_id, query_tag: '')[:results]

      @transactions << tink_transactions
    end

    # mail(subject: 'New income transactions!', to: user.email)
    p "#{ user.first_name } - #{ @transactions.flatten.count }"
  end
end
