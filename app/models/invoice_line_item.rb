class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :time_entry, optional: true
  belongs_to :project, optional: true

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_amount
  after_save :update_invoice_totals
  after_destroy :update_invoice_totals

  def amount
    return self[:amount] if self[:amount].present?
    calculate_amount
    self[:amount]
  end

  private

  def calculate_amount
    self.amount = (quantity * rate).round(2) if quantity.present? && rate.present?
  end

  def update_invoice_totals
    invoice.calculate_totals
    invoice.save! if invoice.persisted?
  end
end
