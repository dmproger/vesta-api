class Api::V1::TransactionsController < ApplicationController
  before_action :set_account

  def index
    transactions = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read'))
                   .transactions(account_id: @account.account_id, query_tag: 'this week')
    render json: {success: true, message: 'transactions', data: persist_transactions(transactions)}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def set_account
    @account = current_user.accounts.find_by(id: params[:account_id])
    render json: {success: false, message: 'invalid account id', data: nil} if @account.blank?
  end

  private

  def persist_transactions(transactions)
    PersistTransaction.new(transactions.dig(:results),
                           current_user,
                           @account).call
  end
end
