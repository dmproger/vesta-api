class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_messages, only: [:index]
  before_action :set_message, only: [:update, :destroy]

  def index
    render json: { success: true, data: @messages }
  end

  def show
    render json: { success: true, data: @message }
  end
  
  def create
    message = Message.create!(message_params.merge(user: current_user))
    render json: { success: true, data: message }
  end

  def update
    @message.update!(message_params)
    render json: { success: true, data: @message.reload }
  end

  def destroy
    @message.destroy!
  end

  private

  def set_messages
    type = params[:type] || ''
    @messages = current_user.send("#{type}messages")
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params[:kind] = params[:kind].to_i if params[:kind]
    params.permit(:kind, :topic, :text, :viewed, :grade, images: [])
  end
end
