class Api::V1::TransactionsController < ApplicationController
  include PeriodParams

  before_action :set_account, except: [:categories, :assign_property, :assign_expense, :all, :types]
  before_action :set_transaction, only: [:update, :assign_property, :assign_expense]
  before_action :set_property, only: [:assign_property]
  before_action :set_category_type, only: [:all, :types]

  skip_before_action :verify_authenticity_token, only: [:all]

  def index
    refresh_transactions if params[:force_refresh] == 'true'
    @transactions = @account.reload.saved_transactions.income.includes(tenant: :joint_tenants)
    process_transactions if params[:force_refresh] == 'true' && current_user.properties.exists? && current_user.tenants.exists?
  rescue RestClient::Exception => e
    render json: { success: false, message: e.message, data: nil }
  end

  def all
    default_expenses!

    set_account if params[:account_id]

    refresh_transactions if params[:force_refresh] == 'true'
    process_transactions if params[:force_refresh] == 'true' && current_user.properties.exists? && current_user.tenants.exists?

    set_period
    filter = { transaction_date: @period }
    filter.merge!({ account_id: @account.id }) if @account
    filter.merge!({ category_type: @category_type }) if @category_type

    transactions =
      current_user.
        saved_transactions.
        includes(:expense).
        where(filter).
        order(transaction_date: :desc).
        select('saved_transactions.*, expenses.name as expense_name, expenses.id as expense_id').
        references(:expense)

    render json: { success: true, data: transactions.map(&:attributes) }
  end

  def types
    transactions_types = SavedTransaction.all.select('distinct category_type')

    filter = { category_type: @category_type } if @category_type
    transactions_types = transactions_types.where(filter) if filter

    render json: { success: true, data: transactions_types.map(&:category_type).sort }
  end

  def categories
    # not actual
    render json: {success: true, message: 'transaction categories', data: SavedTransaction.user_defined_categories}
  end

  def update
    unless @transaction.update(transaction_params)
      return render json: {success: false, message: errors_to_string(@transaction), data: nil}
    end

    render json: {success: true, message: 'transaction updates successfuly', data: @transaction.reload.attributes}
  end

  def assign_property
    @transaction.replace_property(property_id: @property.id,
                                  tenant_id: @property.active_tenant.id).save

    render json: {success: true, message: 'property assigned successfuly!',
                  data: @transaction.as_json(include: :property)}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  def assign_expense
    if request.post?
      set_expense
      set_property

      @transaction.assign_expense(@expense, @property, params[:report_state])
      render json: { success: true, message: 'expenses assigned successfuly!', data: nil }
    end

    if request.delete?
      @transaction.unassign_expense
      render json: { success: true, message: 'expenses unassigned successfuly!', data: nil }
    end

    if request.put? || request.patch?
      @transaction.report_state!(params[:report_state])
      render json: { success: true, message: 'report state change successfuly!', data: params[:report_state] }
    end
  end

  private

  def process_transactions
    Delayed::Job.enqueue AssociateTransactionsWithTenants.new(current_user.id)
  end

  def refresh_transactions
    return refresh_account_transactions if @account

    refresh_all_transactions
  end

  def refresh_all_transactions
    current_user.accounts.each do |account|
      transactions = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read'))
                         .transactions(account_id: account.account_id, query_tag: '')
      persist_transactions(transactions, account) if transactions.any?
    end
  end

  def refresh_account_transactions
    transactions = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'transactions:read'))
                       .transactions(account_id: @account.account_id, query_tag: '')
    persist_transactions(transactions)
  end

  def transaction_params
    params.require(:transaction).permit(:user_defined_category, :report_state)
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

  def set_category_type
    @category_type = params[:type]
  end

  def incorrect_period?
    return true unless params[:start_date].present? && params[:end_date].present?

    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    (start_date > Date.current) || (start_date > end_date)
  end

  def persist_transactions(transactions, account = nil)
    account ||= @account

    PersistTransaction.new(transactions.dig(:results),
                           current_user,
                           account).call
  end

  def default_expenses!
    return unless Expense.defaults(current_user).count.zero?

    Expense.create_defaults(current_user)
  end
end
