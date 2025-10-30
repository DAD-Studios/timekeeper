require 'rails_helper'

RSpec.describe InvoicePaymentsController, type: :controller do
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

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          invoice_id: invoice.id,
          invoice_payment: {
            amount: 500.00,
            payment_date: Date.current,
            payment_method: 'stripe',
            reference_number: 'REF-123',
            notes: 'Test payment'
          }
        }
      end

      it 'creates a new payment' do
        expect {
          post :create, params: valid_params
        }.to change(InvoicePayment, :count).by(1)
      end

      it 'redirects to the invoice' do
        post :create, params: valid_params
        expect(response).to redirect_to(invoice_path(invoice))
      end

      it 'sets a success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Payment was successfully recorded.')
      end

      it 'updates invoice status' do
        post :create, params: valid_params
        expect(invoice.reload.partially_paid?).to be true
      end

      it 'creates payment with all attributes' do
        post :create, params: valid_params
        payment = invoice.reload.payments.last
        expect(payment.amount).to eq(500.00)
        expect(payment.payment_method).to eq('stripe')
        expect(payment.reference_number).to eq('REF-123')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          invoice_id: invoice.id,
          invoice_payment: {
            amount: -100,
            payment_date: Date.current,
            payment_method: 'stripe'
          }
        }
      end

      it 'does not create a payment' do
        expect {
          post :create, params: invalid_params
        }.not_to change(InvoicePayment, :count)
      end

      it 'redirects to invoice with alert' do
        post :create, params: invalid_params
        expect(response).to redirect_to(invoice_path(invoice))
        expect(flash[:alert]).to include('Payment could not be recorded')
      end
    end

    context 'with full payment amount' do
      let(:full_payment_params) do
        {
          invoice_id: invoice.id,
          invoice_payment: {
            amount: 1000.00,
            payment_date: Date.current,
            payment_method: 'check',
            reference_number: 'CHECK-001'
          }
        }
      end

      it 'marks invoice as paid' do
        post :create, params: full_payment_params
        expect(invoice.reload.paid?).to be true
      end

      it 'sets paid_date' do
        post :create, params: full_payment_params
        expect(invoice.reload.paid_date).to eq(Date.current)
      end
    end

    context 'with all payment methods' do
      %w[bank_wire zelle cashapp venmo stripe paypal check cash].each do |method|
        it "creates payment with #{method} method" do
          post :create, params: {
            invoice_id: invoice.id,
            invoice_payment: {
              amount: 100,
              payment_date: Date.current,
              payment_method: method
            }
          }
          payment = invoice.reload.payments.last
          expect(payment.payment_method).to eq(method)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:payment) do
      invoice.payments.create!(
        amount: 500,
        payment_date: Date.current,
        payment_method: 'stripe'
      )
    end

    it 'destroys the payment' do
      expect {
        delete :destroy, params: { invoice_id: invoice.id, id: payment.id }
      }.to change(InvoicePayment, :count).by(-1)
    end

    it 'redirects to the invoice' do
      delete :destroy, params: { invoice_id: invoice.id, id: payment.id }
      expect(response).to redirect_to(invoice_path(invoice))
    end

    it 'sets a success notice' do
      delete :destroy, params: { invoice_id: invoice.id, id: payment.id }
      expect(flash[:notice]).to eq('Payment was successfully deleted.')
    end

    it 'updates invoice status after deletion' do
      invoice.reload
      expect(invoice.partially_paid?).to be true

      delete :destroy, params: { invoice_id: invoice.id, id: payment.id }
      expect(invoice.reload.sent?).to be true
    end

    context 'when deleting one of multiple payments' do
      let!(:payment2) do
        invoice.payments.create!(
          amount: 300,
          payment_date: Date.current,
          payment_method: 'check'
        )
      end

      it 'keeps the invoice in partially_paid status' do
        delete :destroy, params: { invoice_id: invoice.id, id: payment2.id }
        expect(invoice.reload.partially_paid?).to be true
        expect(invoice.amount_paid).to eq(500)
      end
    end
  end
end
