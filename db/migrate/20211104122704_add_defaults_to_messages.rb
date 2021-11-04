class AddDefaultsToMessages < ActiveRecord::Migration[6.0]
  def change
    change_column_default :messages, :kind, from: nil, to: 1
    change_column_default :messages, :department, from: nil, to: 1
  end
end
