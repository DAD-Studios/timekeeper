class Invoice < ApplicationRecord
  belongs_to :client
  has_many :line_items, class_name: 'InvoiceLineItem', dependent: :destroy
  has_many :payments, class_name: 'InvoicePayment', dependent: :destroy
  has_many :time_entries, through: :line_items

  has_rich_text :notes
  has_rich_text :payment_instructions

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: proc { |attributes|
    attributes['description'].blank? && attributes['quantity'].blank? && attributes['rate'].blank?
  }

  enum :status, {
    draft: 0,
    sent: 1,
    viewed: 2,
    paid: 3,
    partially_paid: 4,
    overdue: 5,
    cancelled: 6
  }

  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :due_date, presence: true
  validates :client, presence: true
  validates :status, presence: true

  before_validation :set_invoice_number, on: :create
  before_save :manage_paid_date
  after_save :calculate_totals_after_save

  scope :overdue, -> { where(status: :sent).where('due_date < ?', Date.current) }
  scope :unpaid, -> { where(status: [:sent, :overdue, :partially_paid]) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_paid!(payment_date: Date.current, payment_method: nil, reference_number: nil)
    transaction do
      payments.create!(
        amount: total,
        payment_date: payment_date,
        payment_method: payment_method,
        reference_number: reference_number
      )
      update!(status: :paid, paid_date: payment_date)
    end
  end

  def amount_paid
    payments.sum(:amount)
  end

  def amount_due
    total - amount_paid
  end

  def overdue?
    sent? && due_date < Date.current
  end

  def recalculate_totals!
    calculate_totals
    save!
  end

  def calculate_totals
    self.subtotal = line_items.reload.sum(&:amount)
    self.discount_amount ||= 0
    self.total = subtotal - discount_amount
  end

  def calculate_totals_after_save
    calculate_totals
    update_columns(subtotal: subtotal, total: total) if persisted? && (subtotal_changed? || total_changed?)
  end

  private

  def set_invoice_number
    return if invoice_number.present?

    profile = Profile.first
    if profile
      self.invoice_number = profile.generate_next_invoice_number
    else
      self.invoice_number = "INV-#{Date.current.year}-001"
    end
  end

  def manage_paid_date
    return unless status_changed?

    if paid_status?
      self.paid_date ||= Date.current
    elsif paid_date.present?
      self.paid_date = nil
    end
  end

  def paid_status?
    paid? || partially_paid?
  end
end
