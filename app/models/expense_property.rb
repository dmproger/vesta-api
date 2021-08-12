class ExpenseProperty < ApplicationRecord
  belongs_to :expense
  belongs_to :property
  belongs_to :saved_transaction

  validates :saved_transaction, uniqueness: true
end
