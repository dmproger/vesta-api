json.success true
json.message params[:force_refresh] == 'true' ? 'latest transactions' : 'saved transactions'
json.data @transactions.order(transaction_date: :desc).each do |transaction|
  json.merge! transaction.attributes
  json.category_name(transaction.is_associated ? SavedTransaction::INCOME_CATEGORY_NAME : transaction.expense.name)
end
