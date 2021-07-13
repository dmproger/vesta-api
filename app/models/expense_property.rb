class ExpenseProperty < ApplicationRecord
  belongs_to :user
  belongs_to :property
  belongs_to :expense
end
