class TinkCredential < ApplicationRecord
  belongs_to :account

  def expired?
    !%w[UPDATED CREATED].include?(status)
  end
end
