require 'rails_helper'

RSpec.describe "invoices/create.html.erb", type: :view do
  it "renders the create view" do
    assign(:invoice, Invoice.new)
    assign(:clients, create_list(:client, 1))
    render
    expect(rendered).to match(/Invoices#create/)
  end
end
