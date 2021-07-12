class Expense < ApplicationRecord
  DEFAULTS = %w[
    expense1
    expense2
    expense3
  ]

  belongs_to :user

  def self.defaults(user)
    where(user: user, name: DEFAULTS)
  end

  def self.create_defaults(user)
    (DEFAULTS - joins(:user).where(user: user).map(&:name)).each do |expense|
      create!(user: user, name: expense)
    end
  end

  def self.restore_defaults(user)
    defaults(user).delete_all

    DEFAULTS.each do |expense|
      create!(user: user, name: expense)
    end
  end
end
