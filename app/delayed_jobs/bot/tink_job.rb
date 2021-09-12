require_relative '../../tink_api/v1/client'

MODELS = [Account, SavedTransaction]
require_relative '../../../spec/support/manual/test_user_data'

class Bot::TinkJob < Bot
  USERS = [USER]

  self.cron_expression = '*/1 * * * *'

  def perform
    for user in USERS
      Bot::TinkMailer.with(user: user).income_transactions.deliver_now
      p "======= JOBBER TICK ==========="
    end
  end
end
