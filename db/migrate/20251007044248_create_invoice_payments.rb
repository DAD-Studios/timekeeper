class CreateInvoicePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :payment_date, null: false
      t.string :payment_method
      t.string :reference_number
      t.text :notes

      t.timestamps
    end
  end
end
