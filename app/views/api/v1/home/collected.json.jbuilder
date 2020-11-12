json.success true
json.message 'collected'
json.data @associated_transactions.includes(:tenant, :joint_tenant).each do |at|
  json.id at.id
  json.tenant at.tenant.as_json(include: :joint_tenants)
  json.joint_tenant at.joint_tenant
  json.saved_transaction at.saved_transaction
end