class InvoicePaymentsController < ApplicationController
  before_action :set_invoice

  def create
    @payment = @invoice.payments.build(payment_params)

    if @payment.save
      redirect_to invoice_path(@invoice), notice: 'Payment was successfully recorded.'
    else
      redirect_to invoice_path(@invoice), alert: "Payment could not be recorded: #{@payment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @payment = @invoice.payments.find(params[:id])
    @payment.destroy
    redirect_to invoice_path(@invoice), notice: 'Payment was successfully deleted.'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:invoice_id])
  end

  def payment_params
    params.require(:invoice_payment).permit(:amount, :payment_date, :payment_method, :reference_number, :notes)
  end
end