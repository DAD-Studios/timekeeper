require 'rails_helper'

RSpec.describe "Invoice Status Updates", type: :request do
  let!(:profile) { Profile.create!(
    entity_type: 'individual',
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    invoice_prefix: "INV",
    next_invoice_number: 1
  ) }
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:invoice) { Invoice.create!(
    client: client,
    invoice_number: "INV-001",
    invoice_date: Date.current,
    due_date: Date.current + 30.days,
    status: 'draft'
  ) }

  describe "PATCH /invoices/:id with status update" do
    it "updates the invoice status from draft to sent" do
      patch invoice_path(invoice), params: { invoice: { status: 'sent' } }

      expect(response).to redirect_to(invoice_path(invoice))
      expect(invoice.reload.status).to eq('sent')
    end

    it "updates the invoice status from sent to viewed" do
      invoice.update(status: 'sent')

      patch invoice_path(invoice), params: { invoice: { status: 'viewed' } }

      expect(response).to redirect_to(invoice_path(invoice))
      expect(invoice.reload.status).to eq('viewed')
    end

    it "updates the invoice status from draft to paid" do
      patch invoice_path(invoice), params: { invoice: { status: 'paid' } }

      expect(response).to redirect_to(invoice_path(invoice))
      expect(invoice.reload.status).to eq('paid')
    end

    it "allows status change from paid to partially_paid" do
      invoice.update(status: 'paid')

      patch invoice_path(invoice), params: { invoice: { status: 'partially_paid' } }

      expect(response).to redirect_to(invoice_path(invoice))
      expect(invoice.reload.status).to eq('partially_paid')
    end

    it "prevents editing other fields on paid invoices" do
      invoice.update(status: 'paid')

      patch invoice_path(invoice), params: {
        invoice: {
          status: 'paid',
          discount_amount: 100.00
        }
      }

      expect(response).to redirect_to(invoice_path(invoice))
      expect(flash[:alert]).to match(/Cannot edit a paid invoice/)
      expect(invoice.reload.discount_amount).to eq(0.0)
    end
  end
end
