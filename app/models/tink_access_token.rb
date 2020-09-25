class TinkAccessToken < ApplicationRecord
  belongs_to :user

  def is_expired?
    created_ago_seconds >= expires_in
  end

  def created_ago_seconds
    DateTime.current.to_i - created_at.to_i
  end
end
