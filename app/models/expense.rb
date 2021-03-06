class Expense < ApplicationRecord
  DEFAULTS = [
    'Mortage',
    'Agency fees',
    'Service charge',
    'Ground rent',
    'Insurance',
    'Legal',
    'Professional fees',
    'Repair'
  ].freeze

  belongs_to :user

  has_one :property, through: :expense_property
  has_one :saved_transaction, through: :expense_property

  enum report_state: { hidden: 0, visible: 1 }

  def self.defaults(user)
    where(user: user, name: DEFAULTS)
  end

  def self.create_defaults(user)
    (DEFAULTS - where(user: user).map(&:name)).each do |expense_name|
      create!(user: user, name: expense_name)
    end
  end

  def self.restore_defaults(user)
    defaults(user).delete_all

    DEFAULTS.each do |expense_name|
      create!(user: user, name: expense_name)
    end
  end
end
