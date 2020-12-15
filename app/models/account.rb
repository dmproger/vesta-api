class Account < ApplicationRecord
  belongs_to :user

  has_many :saved_transactions, dependent: :destroy

  after_create :update_username

  private

  def update_username
    if user.first_name&.empty?
      name = holder_name&.split(' ', 2)
      user.update_columns(first_name: name.first, surname: name.last)
    end
  end
end
