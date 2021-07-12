class Api::V1::UserExpensesController < ApplicationController
  before_action :set_expense, only: [:create, :update, :destroy, :show]

  def index
    defaults!

    render json: {
      success: true,
      data: current_user.expenses.select('name').index_by(&:id)
    }
  end

  def create
    expense = current_user.expenses.new(name: params[:expense])

    if expense.save
      render json: { success: true, data: "expense '#{@expense}' successfully created" }
    else
      render json: { success: false, data: expense.errors }
    end
  end

  def update

  end

  def show
  end

  def destroy
  end

  def restore_defaults
  end

  private

  def set_expense
    # TODO
    # @expense = params[:expense]
  end

  def defaults!
    return if Expense.defaults(user).count > 0

    Expense.create_defaults(user)
  end
end
