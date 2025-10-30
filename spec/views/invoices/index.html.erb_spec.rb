require 'rails_helper'

RSpec.describe "invoices/index.html.erb", type: :view do
  it "renders the index view" do
    profile = create(:profile)
    invoices = []
    2.times do
      invoices << create(:invoice)
    end
    assign(:invoices, Kaminari.paginate_array(invoices).page(1))
    render
    expect(rendered).to match(/Invoices/)
  end
end
