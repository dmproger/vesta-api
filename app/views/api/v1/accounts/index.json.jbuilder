json.success true
json.message 'accounts'
json.data do
  json.accounts @accounts.each do |account|
    json.merge! account.attributes
    json.credentials_expired account.credentials_expired?
  end
  json.subscription current_user.active_subscription
end
