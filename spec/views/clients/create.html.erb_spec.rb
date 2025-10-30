require 'rails_helper'

RSpec.describe "clients/create.html.erb", type: :view do
  it "renders the create view" do
    assign(:client, Client.new)
    render
    expect(rendered).to match(/Clients#create/)
  end
end
