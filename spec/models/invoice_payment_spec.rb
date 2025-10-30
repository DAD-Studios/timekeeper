require 'rails_helper'

RSpec.describe InvoicePayment, type: :model do
  let(:client) { Client.create!(name: 'Test Client', email: 'test@example.com') }
  let(:invoice) do
    invoice = Invoice.create!(
      client: client,
      invoice_date: Date.current,
      due_date: Date.current + 30.days,
      status: :draft
    )
    # Add a line item to give the invoice a total
    invoice.line_items.create!(
      description: 'Test Item',
      quantity: 10,
      rate: 100
    )
    invoice.reload
    invoice
  end

  describe 'associations' do
    it { should belong_to(:invoice) }
    it { should have_rich_text(:notes) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:payment_date) }
    it { should validate_presence_of(:payment_method) }

    it 'validates amount is greater than 0' do
      payment = invoice.payments.build(amount: 0, payment_date: Date.current, payment_method: 'check')
      expect(payment).not_to be_valid
      expect(payment.errors[:amount]).to include('must be greater than 0')
    end

    it 'validates amount is numeric' do
      payment = invoice.payments.build(amount: -100, payment_date: Date.current, payment_method: 'check')
      expect(payment).not_to be_valid
    end
  end

  describe 'payment_method enum' do
    it 'has correct payment methods' do
      expect(InvoicePayment.payment_methods.keys).to match_array(%w[
        bank_wire zelle cashapp venmo stripe paypal check cash
      ])
    end

    it 'allows setting payment method' do
      payment = invoice.payments.create!(
        amount: 100,
        payment_date: Date.current,
        payment_method: 'stripe'
      )
      expect(payment.payment_method_stripe?).to be true
    end

    it 'allows all payment methods' do
      %w[bank_wire zelle cashapp venmo stripe paypal check cash].each do |method|
        payment = invoice.payments.create!(
          amount: 100,
          payment_date: Date.current,
          payment_method: method
        )
        expect(payment.payment_method).to eq(method)
        payment.destroy
      end
    end
  end

  describe 'rich text notes' do
    it 'supports rich text formatting' do
      payment = invoice.payments.create!(
        amount: 100,
        payment_date: Date.current,
        payment_method: 'check',
        notes: '<p>Test <strong>bold</strong> text</p>'
      )
      expect(payment.notes).to be_a(ActionText::RichText)
      expect(payment.notes.to_s).to include('bold')
    end
  end

  describe 'callbacks' do
    describe '#update_invoice_status' do
      context 'when payment fully covers invoice' do
        it 'marks invoice as paid' do
          invoice.payments.create!(
            amount: invoice.total,
            payment_date: Date.current,
            payment_method: 'stripe'
          )
          expect(invoice.reload.paid?).to be true
        end

        it 'sets paid_date' do
          payment_date = Date.current - 1.day
          invoice.payments.create!(
            amount: invoice.total,
            payment_date: payment_date,
            payment_method: 'stripe'
          )
          expect(invoice.reload.paid_date).to eq(payment_date)
        end
      end

      context 'when payment partially covers invoice' do
        it 'marks invoice as partially_paid' do
          invoice.payments.create!(
            amount: invoice.total / 2,
            payment_date: Date.current,
            payment_method: 'stripe'
          )
          expect(invoice.reload.partially_paid?).to be true
        end
      end

      context 'when all payments are deleted' do
        it 'reverts invoice to sent status' do
          payment = invoice.payments.create!(
            amount: 500,
            payment_date: Date.current,
            payment_method: 'stripe'
          )
          invoice.reload
          expect(invoice.partially_paid?).to be true

          payment.destroy
          expect(invoice.reload.sent?).to be true
          expect(invoice.paid_date).to be_nil
        end
      end

      context 'when multiple partial payments add up to total' do
        it 'marks invoice as paid' do
          invoice.payments.create!(
            amount: 400,
            payment_date: Date.current,
            payment_method: 'stripe'
          )
          invoice.payments.create!(
            amount: 600,
            payment_date: Date.current,
            payment_method: 'check'
          )
          expect(invoice.reload.paid?).to be true
        end
      end
    end
  end

  describe 'payment amounts' do
    it 'correctly calculates amount_paid for multiple payments' do
      invoice.payments.create!(amount: 300, payment_date: Date.current, payment_method: 'stripe')
      invoice.payments.create!(amount: 200, payment_date: Date.current, payment_method: 'check')
      expect(invoice.reload.amount_paid).to eq(500)
    end

    it 'correctly calculates amount_due' do
      invoice.payments.create!(amount: 300, payment_date: Date.current, payment_method: 'stripe')
      expect(invoice.reload.amount_due).to eq(700)
    end
  end

  describe 'dependent destroy' do
    it 'is destroyed when invoice is destroyed' do
      payment = invoice.payments.create!(
        amount: 100,
        payment_date: Date.current,
        payment_method: 'stripe'
      )
      payment_id = payment.id

      invoice.destroy
      expect(InvoicePayment.exists?(payment_id)).to be false
    end
  end
end
