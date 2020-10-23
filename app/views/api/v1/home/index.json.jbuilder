json.success true
json.message 'home data'
json.data do
  json.period params[:period].presence || Date.current.strftime('%m-%Y')
  json.total @data.first
  json.collected @data.second
  json.expected @data.second_to_last
  json.late @data.last
end