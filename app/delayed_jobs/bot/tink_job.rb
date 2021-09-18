require_relative '../../tink_api/v1/client'

class Bot::TinkJob < Bot
  # temporary testing
  USERS = [User.find_by(phone: '+447722222222')]

  self.cron_expression = '*/5 * * * *'

  def perform
    TinkService.get_rental_payment(USERS)
  end
end
