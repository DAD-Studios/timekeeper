class InvoicePayment < ApplicationRecord
  belongs_to :invoice

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  after_create :update_invoice_status
  after_destroy :update_invoice_status

  private

  def update_invoice_status
    invoice.reload
    total_paid = invoice.amount_paid

    if total_paid >= invoice.total
      invoice.update(status: :paid, paid_date: payment_date)
    elsif total_paid > 0
      invoice.update(status: :partially_paid)
    else
      invoice.update(status: :sent, paid_date: nil)
    end
  end
end
