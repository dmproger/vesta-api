class Account < ApplicationRecord
  belongs_to :user

  has_many :saved_transactions, dependent: :destroy
  has_one :tink_credential

  after_create :update_username

  def credentials_expired?
    tink_credential&.expired? || false
  end

  private

  def update_username
    # TODO данное место тоже может быть багом, так как внутрь блока if можно
    # попасть только тогда, когда имя равно пустой строке (""), но не когда оно
    # не задано (nil).
    if user.first_name&.empty?
      name = holder_name&.split(' ', 2)
      user.update_columns(first_name: name&.first, surname: name&.last)
    end
  end
end
