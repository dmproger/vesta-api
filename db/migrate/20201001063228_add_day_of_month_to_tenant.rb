class AddDayOfMonthToTenant < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :day_of_month, :integer
  end
end
