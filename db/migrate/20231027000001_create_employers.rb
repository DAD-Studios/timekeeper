class CreateEmployers < ActiveRecord::Migration[8.0]
  def change
    create_table :employers do |t|
      t.string :name, null: false
      t.decimal :hourly_rate, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
    add_index :employers, :name, unique: true
  end
end
