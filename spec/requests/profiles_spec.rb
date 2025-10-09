require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:profile) { create(:profile) }

  describe "GET /edit" do
    it "returns http success" do
      get edit_profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the profile" do
      profile # ensure profile exists
      patch profile_path, params: { profile: { business_name: "Updated Company" } }
      expect(response).to redirect_to(edit_profile_path)
      expect(Profile.first.business_name).to eq("Updated Company")
    end
  end

end
