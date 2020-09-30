class Api::V1::AddressesController < ApplicationController
  before_action :set_address, only: [:show, :update, :destroy]

  def index
    render json: {success: true, message: 'addresses', data: current_user.addresses}
  end

  def show
    render json: {success: true, message: 'address', data: @address}
  end

  def create
    address = current_user.addresses.create(address_params)

    if address.persisted?
      render json: {success: true, message: 'created successfully', data: address}
    else
      render json: {success: false, message: errors_to_string(address), data: nil}
    end
  end

  def update
    if @address.update(address_params)
      render json: {success: true, message: 'updated successfully', data: @address}
    else
      render json: {success: false, message: errors_to_string(@address), data: nil}
    end
  end

  def destroy
    @address.destroy
    render json: {success: true, message: 'deleted successfully', data: nil}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  private

  def set_address
    @address = current_user.addresses.find_by(id: params[:id])
    if @address.blank?
      render json: {success: false, message: 'invalid address id', data: nil}
    end
  end

  def address_params
    params.require(:address).permit(:address, :city, :post_code, :country)
  end
end
