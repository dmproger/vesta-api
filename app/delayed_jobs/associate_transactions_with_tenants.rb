class AssociateTransactionsWithTenants < Struct.new(:user_id)
  def perform
    user = User.find_by(id: user_id)
    return if user.blank?

    user.saved_transactions.income.not_processed.each do |transaction|
      tenant = find_matching_tenant(transaction, user)

      mark_unassociated(transaction) and next if tenant.blank?

      joint_tenant = find_joint_tenant(transaction, tenant)

      if transaction.assign_to_tenant(joint_tenant, property_id: tenant.property_id, tenant_id: tenant.id)
        transaction.update(is_processed: true, is_associated: true, association_type: :automatic)
      else
        mark_unassociated(transaction)
      end

      # TODO: Test & Fix ripples of schema changes
    end
  end

  private

  def find_joint_tenant(transaction, tenant)
    tenant.joint_tenants.where(price: transaction.amount)
        .search(transaction.description).first
  end

  def mark_unassociated(transaction)
    transaction.update(is_processed: true, is_associated: false)
  end

  def find_matching_tenant(transaction, user)
    user.tenants
        .within(transaction.transaction_date)
        .where(price: transaction.amount)
        .search(transaction.description).first
  end
end