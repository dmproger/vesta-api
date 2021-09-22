class AssociateTransactionsWithTenants < Struct.new(:user_id)
  def perform
    user = User.find_by(id: user_id)
    return if user.blank?
    return unless user.properties.exists?
    return unless user.tenants.exists?

    user.saved_transactions.income.not_associated.each do |transaction|
      tenant = find_matching_tenant(transaction, user)

      mark_unassociated(transaction) and next if tenant.blank?

      joint_tenant = find_joint_tenant(transaction, tenant)

      if transaction.assign_to_tenant(joint_tenant, property_id: tenant.property_id, tenant_id: tenant.id)
        transaction.update(is_processed: true, is_associated: true, association_type: :automatic)
      else
        mark_unassociated(transaction)
      end
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
    # this extra query is fetching tenant ids based on joint_tenants because pg_search does not support
    # includes with associated search
    #
    # where(price: transaction.amount) in tenant_ids and tenatns old algorithm
    # new algirithm - search only on transaction.description
    # Checkout it, may not work
    #
    joint_tenants = user.tenants.includes(:joint_tenants)
    user.
      tenants.
        within(transaction.transaction_date).
        or(
          user.
            tenants.
              within(transaction.transaction_date).
              where(id: joint_tenants.ids)
        )
        .search(transaction.description).
        references(:joint_tenants).
        first
  end
end
