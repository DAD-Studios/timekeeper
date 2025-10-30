require 'rails_helper'

RSpec.describe "clients/edit.html.erb", type: :view do
  it "renders the edit view" do
    assign(:client, create(:client))
    render
    expect(rendered).to match(/Edit Client/)
  end
end
