require 'rails_helper'

RSpec.describe "clients/destroy.html.erb", type: :view do
  it "renders the destroy view" do
    assign(:client, create(:client))
    render
    expect(rendered).to match(/Clients#destroy/)
  end
end
