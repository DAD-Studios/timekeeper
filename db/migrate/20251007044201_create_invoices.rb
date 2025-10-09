class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :client, null: false, foreign_key: true
      t.references :employer, null: true, foreign_key: true
      t.string :invoice_number, null: false
      t.integer :status, default: 0, null: false
      t.date :invoice_date, null: false
      t.date :due_date, null: false
      t.date :paid_date
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, default: 0
      t.text :notes
      t.text :payment_instructions
      t.string :po_number
      t.datetime :sent_at
      t.string :sent_to_email

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
  end
end
