class Expense < ApplicationRecord
  DEFAULTS = [
    'Mortage',
    'Bills',
    'Service charge',
    'Ground rent',
    'Insurance',
    'Legal',
    'Professional fees',
    'Repair'
  ].freeze

  belongs_to :user
  has_one :property, through: :expense_properties

  def self.defaults(user)
    where(user: user, name: DEFAULTS)
  end

  def self.create_defaults(user)
    (DEFAULTS - where(user: user).map(&:name)).each do |expense|
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
