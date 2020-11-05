json.success true
json.message params[:test] == 'true' ? 'test data' : 'home data'
json.data do
  json.has_properties current_user.properties.exists?
  json.period params[:period].presence || Date.current.strftime('%m-%Y')
  json.total @data.first
  json.collected @data.second
  json.expected @data.second_to_last
  json.late @data.last
end