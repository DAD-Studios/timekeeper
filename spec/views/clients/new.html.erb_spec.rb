require 'rails_helper'

RSpec.describe "clients/new.html.erb", type: :view do
  it "renders the new view" do
    assign(:client, Client.new)
    render
    expect(rendered).to match(/New Client/)
  end
end
