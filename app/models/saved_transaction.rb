class SavedTransaction < ApplicationRecord
  DEFAULT_REPORT_STATE = :visible

  belongs_to :account
  belongs_to :user

  scope :within, -> (period) {where(transaction_date: period.beginning_of_month..period.end_of_month)}
  scope :income, -> {where(category_type: %w[INCOME TRANSFERS]).where('amount >= ?', 0)}
  scope :not_processed, -> {where(is_processed: false)}
  scope :not_associated, -> {where(is_associated: false)}

  has_one :associated_transaction, dependent: :destroy

  has_one :property_tenant, through: :associated_transaction

  has_one :property, through: :property_tenant,
           class_name: 'Property'

  has_one :tenant, through: :property_tenant,
          class_name: 'Tenant'

  has_one :expense_property, dependent: :destroy
  has_one :expense, through: :expense_property

  enum user_defined_category: [:rent, :mortgage, :ground_rent, :other]
  enum association_type: [:automatic, :manual]

  enum report_state: %i[hidden visible]

  def self.from_tink(tink_transactions)
    # TODO
  end

  def assign_to_tenant(joint_tenant, attributes = nil)
    property_tenant = find_property_tenant(attributes) || PropertyTenant.create(attributes)
    property_tenant.associated_transactions.create!(saved_transaction_id: id,
                                                   joint_tenant_id: joint_tenant&.id)
  rescue StandardError => _e
    puts _e.message
    false
  end

  def find_property_tenant(attributes)
    PropertyTenant.where(attributes).within(transaction_date).first
  end

  def replace_property(attributes = nil)
    PropertyTenant.transaction do
      property_tenant&.destroy!
      create_property_tenant!(attributes)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    property_tenant
  end

  def assign_expense(expense, property, report_state = nil)
    raise ActiveRecord::RecordInvalid unless /EXPENSE/.match(category_type)

    unassign_expense if expense_property
    ExpenseProperty.create!(saved_transaction: self, expense: expense, property: property)

    report_state!(report_state || DEFAULT_REPORT_STATE)
  end

  def unassign_expense
    # secondary operation just in case, if multiple records (now restricted on model)
    expense_property.destroy! && ExpenseProperty.where(saved_transaction: self).delete_all

    report_state!(nil)
  end

  def report_state!(report_state)
    self.report_state = report_state
    save!
  end
end
