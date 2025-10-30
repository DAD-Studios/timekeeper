require 'rails_helper'

RSpec.describe "clients/index.html.erb", type: :view do
  it "renders the index view" do
    clients = create_list(:client, 2)
    assign(:clients, Kaminari.paginate_array(clients).page(1))
    render
    expect(rendered).to match(/Clients/)
  end
end
