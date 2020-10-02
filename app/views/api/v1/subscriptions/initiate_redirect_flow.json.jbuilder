json.success true
json.message 'please redirect user to following link'
json.data do
  json.redirect_flow_id @redirect_flow.id
  json.redirect_url @redirect_flow.redirect_url
end