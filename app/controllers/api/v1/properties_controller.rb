class Api::V1::PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :summary, :update, :destroy, :archive]

  def index
    @properties = current_user.properties.non_archived.includes(:tenants)
  end

  def show
    render json: {success: true, message: 'property', data: @property}
  end

  def summary
    current_user.saved_transactions.where(property: @property).sum(:amount)
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

  def property_params
    params.require(:property).permit(:address, :city, :post_code, :country)
  end
end
