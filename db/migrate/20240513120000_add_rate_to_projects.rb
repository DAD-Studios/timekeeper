class AddRateToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :rate, :decimal, precision: 10, scale: 2
  end
end
