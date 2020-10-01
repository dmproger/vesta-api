json.success true
json.message 'created successfully'
json.data do
  json.merge! @tenant.attributes
  json.agency_agreement @tenant.agency_agreement_url
  json.tenancy_agreement @tenant.tenancy_agreement_url
  json.joint_tenants @tenant.joint_tenants
end