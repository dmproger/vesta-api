require_relative '../../../app/services/tink_service'

class Bot::TinkJob < ApplicationJob
  # temporary testing
  USERS = [User.find_by(phone: '+447722222222')]

  def perform
    TinkService.get_rental_payment(USERS)
  end
end
