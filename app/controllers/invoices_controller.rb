class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :mark_paid, :download_pdf, :destroy]

  def index
    @invoices = Invoice.includes(:client, :client).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @invoice = Invoice.new
    @clients = Client.all

    respond_to do |format|
      format.html
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    if @invoice.paid?
      redirect_to invoice_path(@invoice), alert: 'Cannot edit a paid invoice.'
      return
    end
    @clients = Client.all
  end

  def update
    @invoice = Invoice.find(params[:id])

    # Allow status-only updates even for paid invoices
    if @invoice.paid? && invoice_params.keys.sort != ['status']
      redirect_to invoice_path(@invoice), alert: 'Cannot edit a paid invoice. Only status can be changed.'
      return
    end

    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: 'Invoice was successfully updated.'
    else
      @clients = Client.all
      render :edit, status: :unprocessable_content
    end
  end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: 'Invoice was successfully created.'
    else
      @clients = Client.all
      render :new, status: :unprocessable_content
    end
  end

  def mark_paid
    @invoice.mark_as_paid!
    redirect_to invoice_path(@invoice), notice: 'Invoice marked as paid.'
  end

  def download_pdf
    pdf = InvoicePdfGenerator.new(@invoice).generate
    send_data pdf.render,
              filename: "#{@invoice.invoice_number}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: 'Invoice was successfully deleted.'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:client_id, :client_id, :invoice_date, :due_date, :status,
                                   :tax_rate, :discount_amount, :notes, :payment_instructions,
                                   line_items_attributes: [:id, :time_entry_id, :description, :quantity, :rate, :_destroy])
  end
end
