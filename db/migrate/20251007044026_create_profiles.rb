class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.integer :entity_type, default: 0, null: false
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :business_name
      t.string :tax_id
      t.string :email, null: false
      t.string :phone
      t.string :website
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'USA'
      t.string :invoice_prefix, default: 'INV'
      t.integer :next_invoice_number, default: 1
      t.integer :default_payment_terms, default: 30
      t.text :default_invoice_notes
      t.text :default_payment_instructions
      t.string :primary_color, default: '#5cb85c'
      t.boolean :show_logo, default: true

      t.timestamps
    end
  end
end
