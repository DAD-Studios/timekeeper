require 'rails_helper'

RSpec.describe "invoices/new.html.erb", type: :view do
  it "renders the new view" do
    assign(:invoice, Invoice.new)
    assign(:clients, create_list(:client, 1))
    render
    expect(rendered).to match(/New Invoice/)
  end
end
