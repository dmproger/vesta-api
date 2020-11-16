json.success true
json.message 'all home data'
json.data do
  json.has_properties current_user.properties.exists?
  json.period params[:period].presence || Date.current.strftime('%m-%Y')
  json.total @data.first
  json.collected @data.second
  json.expected @data.second_to_last
  json.late @data.last

  json.collected_details @associated_transactions.includes(:tenant, :joint_tenant).each do |at|
    json.id at.id
    json.tenant at.tenant.as_json(include: :joint_tenants)
    json.joint_tenant at.joint_tenant
    json.saved_transaction at.saved_transaction
  end

  json.expected_details @expected_tenants
  json.late_details @late_tenants
end