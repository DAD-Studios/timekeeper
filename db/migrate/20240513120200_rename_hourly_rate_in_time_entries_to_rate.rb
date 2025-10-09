class RenameHourlyRateInTimeEntriesToRate < ActiveRecord::Migration[8.0]
  def change
    rename_column :time_entries, :hourly_rate, :rate
  end
end
