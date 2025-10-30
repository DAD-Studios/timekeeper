require 'rails_helper'

RSpec.describe "profiles/edit.html.erb", type: :view do
  it "renders the edit view" do
    assign(:profile, create(:profile))
    render
    expect(rendered).to match(/Profile Settings/)
  end
end
