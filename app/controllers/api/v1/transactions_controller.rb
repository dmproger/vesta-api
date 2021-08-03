class Api::V1::TransactionsController < ApplicationController
  before_action :set_account, except: [:categories, :assign_property, :assign_expenses, :all, :types]
  before_action :set_transaction, only: [:update, :assign_property, :assign_expenses]
  before_action :set_property, only: [:assign_property, :assign_expenses]
  before_action :set_expense, only: [:assign_expenses]
  before_action :set_category_type, only: [:all]

  def index
    refresh_transactions if params[:force_refresh] == 'true'
    @transactions = @account.reload.saved_transactions.income.includes(tenant: :joint_tenants)
    process_transactions if params[:force_refresh] == 'true' && current_user.properties.exists? && current_user.tenants.exists?
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def all
    set_period
    filter = { transaction_date: @period }
    filter.merge!({ category_type: @category_type }) if @category_type

    transactions = current_user.saved_transactions.where(filter).order(transaction_date: :desc)

    render json: { succes: true, data: transactions.map(&:attributes) }
  end

  def types
    transactions_types = SavedTransaction.all.select('distinct category_type').map(&:category_type).sort

    render json: { success: true, data: transactions_types }
  end

  def categories
    # not actual
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

  def set_period
    @period =
      case [params[:start_date].present?, params[:end_date].present?]
      when [true, true]
        Date.parse(params[:start_date])..Date.parse(params[:end_date])
      when [true, false]
        Date.parse(params[:start_date])..
      when [false, true]
        ..Date.parse(params[:end_date])
      else
        (Date.current - 100.years)..(Date.current + 100.years)
      end
  end

  def set_category_type
    @category_type = params[:type]
  end

  def incorrect_period?
    return true unless params[:start_date].present? && params[:end_date].present?

    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    (start_date > Date.current) || (start_date > end_date)
  end

  def persist_transactions(transactions)
    PersistTransaction.new(transactions.dig(:results),
                           current_user,
                           @account).call
  end
end
