class Profile < ApplicationRecord
  enum :entity_type, { individual: 0, business: 1 }

  # Attachments
  has_one_attached :logo
  has_one_attached :signature

  # Rich Text
  has_rich_text :default_invoice_notes
  has_rich_text :default_payment_instructions

  # Validations
  validates :entity_type, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :business_name, presence: true, if: -> { business? }
  validates :first_name, presence: true, if: -> { individual? }
  validates :last_name, presence: true, if: -> { individual? }
  validates :invoice_prefix, presence: true
  validates :next_invoice_number, presence: true, numericality: { greater_than: 0 }
  validates :default_payment_terms, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Methods
  def display_name
    if business?
      business_name
    else
      "#{first_name} #{last_name}".strip
    end
  end

  def full_address
    [
      address_line1,
      address_line2,
      [city, state, zip_code].compact.join(', '),
      country
    ].compact.reject(&:blank?).join("\n")
  end

  def generate_next_invoice_number
    current_number = next_invoice_number
    increment!(:next_invoice_number)
    "#{invoice_prefix}-#{Date.current.year}-#{current_number.to_s.rjust(3, '0')}"
  end
end
