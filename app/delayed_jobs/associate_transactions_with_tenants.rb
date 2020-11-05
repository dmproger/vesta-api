class AssociateTransactionsWithTenants < Struct.new(:user_id)
  def perform
    user = User.find_by(id: user_id)
    return if user.blank?

    user.saved_transactions.income.not_processed.each do |transaction|
      tenant = find_matching_tenant(transaction, user)

      puts 'tenant'
      puts tenant.blank?

      mark_unassociated(transaction) and next if tenant.blank?

      if transaction.replace_property(property_id: tenant.property_id, tenant_id: tenant.id).save
        transaction.update(is_processed: true, is_associated: true, association_type: :automatic)
      else
        mark_unassociated(transaction)
      end
    end
  end

  private

  def mark_unassociated(transaction)
    transaction.update(is_processed: true, is_associated: false)
  end

  def find_matching_tenant(transaction, user)
    puts transaction.transaction_date
    puts transaction.amount

    user.tenants
        .within(transaction.transaction_date)
        .where(price: transaction.amount)
        .search(transaction.description).first
  end
end