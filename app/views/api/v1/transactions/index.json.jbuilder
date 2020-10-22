json.success true
json.message params[:force_refresh] == 'true' ? 'latest transactions' : 'saved transactions'
json.date @transactions.each do |transaction|
  json.merge! transaction.attributes
  json.tenant transaction.tenant.as_json(include: :joint_tenants)
end