require 'rails_helper'

RSpec.describe "clients/show.html.erb", type: :view do
  it "renders the show view" do
    client = create(:client)
    assign(:client, client)
    render
    expect(rendered).to match(/#{client.name}/)
  end
end
