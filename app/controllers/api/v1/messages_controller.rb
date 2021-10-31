class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_messages

  def index
  end

  def show
  end
  
  def create
  end

  def update
  end

  def destroy
  end

  private

  def set_messages
    type = params[:type] || ''
    @messages = current_user.send("#{type}messages")
  end
end
