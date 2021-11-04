class Message < ApplicationRecord
  DEPARTMENTS = {
    support: 'Support'
  }
  KINDS = {
    income: 'Income',
    outcome: 'Outcome'
  }

  belongs_to :user

  enum kind: { outcome: 1, income: 2 }
  enum department: { support: 1 }

  # has_many_attached :images

  scope :income, ->{ where(kind: :income) }
  scope :outcome, ->{ where(kind: :income) }

  def self.departments_list
    DEPARTMENTS
  end

  def self.kinds_list
    KINDS
  end
end
