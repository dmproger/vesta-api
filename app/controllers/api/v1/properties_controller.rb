class Api::V1::PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :update, :destroy, :archive]
  before_action :set_period, only: [:collected_summary, :expenses_summary]

  def index
    @properties = current_user.properties.non_archived.includes(:tenants)
  end

  def show
    render json: {success: true, message: 'property', data: @property}
  end

  def collected_summary
    if incorrect_period?
      return render json: { success: false, message: 'incorrect date period', date: [@period.first, @period.last] }
    end

    transactions =
      current_user.
        saved_transactions.income.
        where(transaction_date: @period).
        joins(associated_transaction: :property)

    if params[:id]
      set_property
      transactions = transactions.where(property_tenants: { property: @property })
    end

    render json: { success: true, data: transactions.sum(:amount).to_f.round(2) || 0 }
  end

  def expenses_summary
    if params[:id]
      set_property

      @property.expense_transactions.sum(:amount)
    end
  end

  def create
    property = current_user.properties.create(property_params)

    if property.persisted?
      render json: {success: true, message: 'created successfully', data: property}
    else
      render json: {success: false, message: errors_to_string(property), data: nil}
    end
  end

  def update
    if @property.update(property_params)
      render json: {success: true, message: 'updated successfully', data: @property}
    else
      render json: {success: false, message: errors_to_string(@property), data: nil}
    end
  end

  def archive
    if @property.update(is_archived: true, archived_at: Date.current)
      render json: {success: true, message: 'archived successfully', data: nil}
    else
      render json: {success: false, message: errors_to_string(@property), data: nil}
    end
  end

  def destroy
    @property.destroy
    render json: {success: true, message: 'deleted successfully', data: nil}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  private

  def set_property
    @property = current_user.properties.find_by(id: params[:id])
    if @property.blank?
      render json: {success: false, message: 'invalid property id', data: nil}
    end
  end

  def set_period
    @period = (Date.parse(params[:start_date])..Date.parse(params[:end_date]))
  end

  def incorrect_period?
    return true unless params[:start_date].present? && params[:end_date].present?

    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    (start_date > Date.current) || (start_date > end_date)
  end

  def property_params
    params.require(:property).permit(:address, :city, :post_code, :country)
  end
end
