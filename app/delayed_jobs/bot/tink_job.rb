require_relative '../../tink_api/v1/client'
require_relative '../../../app/services/tink_service'

class Bot::TinkJob < ApplicationJob
  # temporary testing
  USERS = [User.find_by(phone: '+447722222222')]

  # self.cron_expression = '*/5 * * * *'

  def perform
    p "=============================="
    TinkService.get_rental_payment(USERS)
  end
end
