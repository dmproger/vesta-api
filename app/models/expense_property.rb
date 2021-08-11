class ExpenseProperty < ApplicationRecord
  belongs_to :expense
  belongs_to :property
  belongs_to :saved_transaction

  # TODO
  # db validate uniq expense, saved_transaction
end
