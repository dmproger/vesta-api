class User::Operation::Reset < ApplicationRecord
  self.table_name = 'users'

  validate :prevent_modify_user, if: :phone_changed?
  validate :prevent_modify_user, if: :email_changed?
  validate :prevent_modify_user, if: :firstname_changed?

  before_save :set_user
  before_save :operation!

  private

  def set_user
    @user = User.find(id)
  end

  def operation!
    reset_properties! if reset_properties.present?
    reset_tenants! if reset_tenants.present?
    reset_accounts! if reset_accounts.present?
    reset_transactions! if reset_transactions.present?

    normal_state
  end

  def prevent_modify_user
    errors.add(:base, :cannot_modify_user)
  end

  def normal_state
    self.reset_properties = false
    self.reset_tenants = false
    self.reset_accounts = false
  end

  def reset_properties!
    @user.properties.delete_all
  end

  def reset_tenants!
    @user.tenants.delete_all
  end

  def reset_accounts!
    @user.accounts.delete_all
  end

  def reset_transactions!
    @user.saved_transactions.delete_all
  end
end
