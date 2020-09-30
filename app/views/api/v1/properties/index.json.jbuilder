json.success true
json.message 'properties'
json.data @properties.each do |property|
  json.merge! property.attributes
  json.active_tenant property.active_tenant
end