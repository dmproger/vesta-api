class Api::V1::TransactionsController < ApplicationController
  before_action :set_account, except: [:categories, :assign_property, :assign_expenses]
  before_action :set_transaction, only: [:update, :assign_property, :assign_expenses]
  before_action :set_property, only: [:assign_property, :assign_expenses]
  before_action :set_expense, only: [:assign_expenses]

  def index
    refresh_transactions if params[:force_refresh] == 'true'
    @transactions = @account.reload.saved_transactions.income.includes(tenant: :joint_tenants)
    process_transactions if params[:force_refresh] == 'true' && current_user.properties.exists? && current_user.tenants.exists?
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def categories
    render json: {success: true, message: 'transaction categories', data: SavedTransaction.user_defined_categories}
  end

  def update
    unless @transaction.update(transaction_params)
      render json: {success: false, message: errors_to_string(@transaction), data: nil}
    end
  end

  def assign_property
    @transaction.replace_property(property_id: @property.id,
                                  tenant_id: @property.active_tenant.id).save

    render json: {success: true, message: 'property assigned successfuly!',
                  data: @transaction.as_json(include: :property)}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  def assign_expenses
    @property.assign_expense(@expense, @transaction)

    render json: {success: true, message: 'expenses assigned successfuly!', data: nil }
  end

  private

  def process_transactions
    Delayed::Job.enqueue AssociateTransactionsWithTenants.new(current_user.id)
  end

  def refresh_transactions
    transactions = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read'))
                       .transactions(account_id: @account.account_id, query_tag: '')
    persist_transactions(transactions)
  end

  def transaction_params
    params.require(:transaction).permit(:user_defined_category)
  end

  def set_transaction
    @transaction = current_user.saved_transactions.find_by(id: params[:id])
    render json: {success: false, message: 'invalid transaction id', data: nil} if @transaction.blank?
  end

  def set_account
    @account = current_user.accounts.find_by(id: params[:account_id])
    render json: {success: false, message: 'invalid account id', data: nil} if @account.blank?
  end

  def set_property
    @property = current_user.properties.find_by(id: params[:property_id])
    render json: {success: false, message: 'invalid property id', data: nil} if @property.blank?
  end

  def set_expense
    @expense = current_user.expenses.find(params[:expense_id])
    render json: {success: false, message: 'invalid expense id', data: nil} if @expense.blank?
  end

  def persist_transactions(transactions)
    PersistTransaction.new(transactions.dig(:results),
                           current_user,
                           @account).call
  end
end
