require 'rails_helper'

RSpec.describe "clients/update.html.erb", type: :view do
  it "renders the update view" do
    assign(:client, create(:client))
    render
    expect(rendered).to match(/Clients#update/)
  end
end
