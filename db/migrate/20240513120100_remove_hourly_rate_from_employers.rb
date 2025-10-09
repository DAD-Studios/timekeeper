class RemoveHourlyRateFromEmployers < ActiveRecord::Migration[8.0]
  def change
    remove_column :employers, :hourly_rate, :decimal
  end
end
