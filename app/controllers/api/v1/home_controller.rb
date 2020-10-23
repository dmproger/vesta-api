class Api::V1::HomeController < ApplicationController
  def index
    @data = HomeData.new(period: params[:period], current_user: current_user).call
  end
end
