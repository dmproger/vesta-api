class Api::V1::ExpensesController < ApplicationController
  before_action :set_attrs
  before_action :set_expense, except: :index

  def index
    defaults!

    render json: {
      success: true,
      data: current_user.expenses.map { |record| record.attributes.slice(*%w[id name report_state]) }
    }
  end

  def create
    save_expense
  end

  def update
    @expense.assign_attributes(@attrs)

    save_expense
  end

  def show
    render json: { success: true, date: @expense.attributes.slice(*%w[id name report_state]) }
  end

  def destroy
    if @expense.destroy
      render json: { success: true, message: 'Expense successfuly destroyed', data: @expense.attributes }
    else
      render json: { success: false, data: @expense.errors }
    end
  end

  def restore_defaults
    Expense.restore_defaults(current_user)

    render json: { success: true, data: "Expenses defaults #{ Expense::DEFAULTS } restored successfuly!" }
  end

  private

  def set_attrs
    @attrs = {}

    %i[name report_state].each do |attr|
      @attrs.merge!(attr => params[attr]) if params[attr]
    end
  end

  def set_expense
    @expense =
      case action_name
      when 'show', 'update', 'destroy'
        current_user.expenses.find(params[:id])
      when 'create'
        current_user.expenses.new(@attrs)
      end
  end

  def save_expense
    if @expense.save
      render json: { success: true, message: 'Expense successfuly saved!', data: @expense.attributes }
    else
      render json: { success: false, data: @expense.errors }
    end
  end

  def defaults!
    return unless Expense.defaults(current_user).count.zero?

    Expense.create_defaults(current_user)
  end
end
