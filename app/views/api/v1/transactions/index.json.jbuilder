json.success true
json.message params[:force_refresh] == 'true' ? 'latest transactions' : 'saved transactions'
json.data @transactions.group_by(&:transaction_date).as_json(include: {tenant: {include: :joint_tenants}})
