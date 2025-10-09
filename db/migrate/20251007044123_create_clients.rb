class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'USA'
      t.text :notes
      t.references :employer, null: true, foreign_key: true

      t.timestamps
    end
  end
end
