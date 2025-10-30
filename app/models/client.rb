class Client < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :invoices, dependent: :destroy

  has_rich_text :notes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def contact_name
    [first_name, last_name].compact.join(' ').presence
  end

  def full_address
    [
      address_line1,
      address_line2,
      [city, state, zip_code].compact.join(', '),
      country
    ].compact.reject(&:blank?).join("\n")
  end
end
