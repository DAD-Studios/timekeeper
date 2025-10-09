class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.string :task, null: false
      t.text :notes
      t.references :project, null: false, foreign_key: true
      t.references :employer, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :duration_seconds
      t.decimal :hourly_rate, precision: 10, scale: 2
      t.decimal :earnings, precision: 10, scale: 2
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
