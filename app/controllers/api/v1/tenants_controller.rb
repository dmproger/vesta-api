class Api::V1::TenantsController < ApplicationController
  before_action :set_property, only: [:create, :show, :update, :destroy, :index]

  before_action :set_tenant, only: [:show, :update, :destroy]

  def index; end

  def show; end

  def create
    @tenant = @property.tenants.create(tenants_params)

    unless @tenant.persisted?
      render json: {success: false, message: errors_to_string(@tenant), data: nil}
    end
  end

  def update
    unless @tenant.update(tenants_params)
      render json: {success: false, message: errors_to_string(@tenant), data: nil}
    end
  end

  def destroy
    @tenant.destroy
    render json: {success: true, message: 'deleted successfully', data: nil}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  private

  def set_property
    @property = current_user.properties
                    .find_by(id: params[:property_id])

    if @property.blank?
      render json: {success: false, message: 'invalid property id', data: nil}
    end
  end

  def set_tenant
    @tenant = @property.tenants.find_by(id: params[:id])

    if @tenant.blank?
      render json: {success: false, message: 'invalid tenant id', data: nil}
    end
  end

  def tenants_params
    params.require(:tenant).permit(:price, :day_of_month, :payment_frequency, :start_date,
                                   :end_date, :name, :email, :phone, :payee_type,
                                   :agency_agreement, :tenancy_agreement, :is_active,
                                   joint_tenants_attributes: [:id, :name, :email, :price, :phone, :day_of_month, :_destroy])
  end
end
