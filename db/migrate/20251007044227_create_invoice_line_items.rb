class CreateInvoiceLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :time_entry, null: true, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :rate, precision: 10, scale: 2, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
