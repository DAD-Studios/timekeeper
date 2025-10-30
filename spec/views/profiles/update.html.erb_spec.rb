require 'rails_helper'

RSpec.describe "profiles/update.html.erb", type: :view do
  it "renders the update view" do
    assign(:profile, create(:profile))
    render
    expect(rendered).to match(/Profiles#update/)
  end
end
