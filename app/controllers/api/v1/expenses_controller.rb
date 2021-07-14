class Api::V1::ExpensesController < ApplicationController
  before_action :set_expense, only: [:create, :update, :destroy, :show]

  def index
    defaults!

    render json: {
      success: true,
      data: current_user.expenses.select('id, name')
    }
  end

  def create
    save_expense
  end

  def update
    @expense.name = params[:name]
    save_expense
  end

  def show
    render json: { success: true, date: @expense.attributes.slice('id', 'name') }
  end

  def destroy
    if @expense.destroy
      render json: { success: true, data: "expense '#{@expense}' destroyed successfuly!" }
    else
      render json: { success: false, data: @expense.errors }
    end
  end

  def restore_defaults
    Expense.restore_defaults(current_user)

    render json: { success: true, data: "Expenses defaults #{ Expense::DEFAULTS } restored successfuly!" }
  end

  private

  def set_expense
    @expense =
      case action_name
      when 'show', 'update', 'destroy'
        Expense.find(params[:id])
      when 'create'
        current_user.expenses.new(name: params[:name])
      end
  end

  def save_expense
    if @expense.save
      render json: { success: true, data: "expense '#{@expense}' successfully saved!" }
    else
      render json: { success: false, data: @expense.errors }
    end
  end

  def defaults!
    return unless Expense.defaults(current_user).count == 0

    Expense.create_defaults(current_user)
  end
end
