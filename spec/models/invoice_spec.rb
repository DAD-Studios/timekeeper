require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:client) { Client.create!(name: "Test Client") }
  let(:invoice) { Invoice.create!(
    client: client,
    invoice_number: "INV-001",
    invoice_date: Date.current,
    due_date: Date.current + 30.days,
    status: 'draft'
  ) }

  describe 'status and paid_date management' do
    it 'automatically sets paid_date when status changes to paid' do
      expect(invoice.paid_date).to be_nil

      invoice.update(status: 'paid')

      expect(invoice.paid_date).to eq(Date.current)
    end

    it 'does not overwrite existing paid_date when changing to paid' do
      specific_date = Date.current - 5.days
      invoice.update(status: 'paid', paid_date: specific_date)

      expect(invoice.paid_date).to eq(specific_date)
    end

    it 'clears paid_date when changing away from paid status' do
      invoice.update(status: 'paid')
      expect(invoice.paid_date).to eq(Date.current)

      invoice.update(status: 'draft')

      expect(invoice.paid_date).to be_nil
    end

    it 'keeps paid_date when status changes from paid to partially_paid' do
      invoice.update(status: 'paid')
      original_paid_date = invoice.paid_date

      invoice.update(status: 'partially_paid')

      expect(invoice.paid_date).to eq(original_paid_date)
    end
  end
end
