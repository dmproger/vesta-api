json.success true
json.message 'created successfully'
json.data do
  json.merge! @subscription.reload.attributes
  json.redirect_flow_id @redirect_flow&.id
  json.redirect_url @redirect_flow&.redirect_url
end