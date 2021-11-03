class ChangeMessages < ActiveRecord::Migration[6.0]
  def change
    remove_column :messages, :reciver, :uuid
    add_column :messages, :department, :integer
  end
end
