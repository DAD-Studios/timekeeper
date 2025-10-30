require 'rails_helper'

RSpec.describe "invoices/show.html.erb", type: :view do
  it "renders the show view" do
    profile = create(:profile)
    invoice = create(:invoice)
    payment = create(:invoice_payment, invoice: invoice)
    assign(:invoice, invoice)
    render
    expect(rendered).to match(/#{invoice.invoice_number}/)
  end
end
