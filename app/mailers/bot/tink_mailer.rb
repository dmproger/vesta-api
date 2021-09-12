require_relative '../../tink_api/v1/client'

class Bot::TinkMailer < ActionMailer
  default from: 'notifier@vesta_app.com'

  def income_transactions
    service = TinkAPI::V1::Client.new(params[:user].valid_tink_token(scopes: 'transactions:read'))

    @transactions = []

    for account in user.accounts
      # transactions = account.saved_transactions.income

      tink_transactions <<
        service.
          transactions(account_id: account.account_id, query_tag: '').
          data[:results]

      @transactions << tink_transactions
    end

    # mail(subject: 'New income transactions!', to: user.email)
    p "#{ user.name } - #{ @transactions.flatten.count }"
  end
end
