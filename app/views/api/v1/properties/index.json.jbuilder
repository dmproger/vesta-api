json.success true
json.message 'properties'
json.data @properties.each do |property|
  json.merge! property.attributes
  json.tenant property.active_tenant || property.latest_tenant
end