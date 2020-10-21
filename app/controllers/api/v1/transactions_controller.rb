class Api::V1::TransactionsController < ApplicationController
  before_action :set_account, except: :categories
  before_action :set_transaction, only: :update

  def index
    transactions = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read'))
                   .transactions(account_id: @account.account_id, query_tag: 'this month')
    render json: {success: true, message: 'transactions', data: persist_transactions(transactions)}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def set_account
    @account = current_user.accounts.find_by(id: params[:account_id])
    render json: {success: false, message: 'invalid account id', data: nil} if @account.blank?
  end

  def categories
    render json: {success: true, message: 'transaction categories', data: SavedTransaction.user_defined_categories}
  end

  def update
    unless @transaction.update(transaction_params)
      render json: {success: false, message: errors_to_string(@transaction), data: nil}
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:user_defined_category)
  end

  def set_transaction
    @transaction = @account.saved_transactions.find_by(id: params[:id])
  end

  def persist_transactions(transactions)
    PersistTransaction.new(transactions.dig(:results),
                           current_user,
                           @account).call
  end
end
