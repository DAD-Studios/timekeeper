require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  describe "GET #edit" do
    context "when a profile exists" do
      let!(:profile) { Profile.create!(entity_type: :individual, first_name: "John", last_name: "Doe", email: "john@example.com", invoice_prefix: "INV", next_invoice_number: 1) }

      it "returns a success response" do
        get :edit
        expect(response).to be_successful
      end

      it "assigns the existing profile" do
        get :edit
        expect(assigns(:profile)).to eq(profile)
      end
    end

    context "when no profile exists" do
      it "returns a success response" do
        get :edit
        expect(response).to be_successful
      end

      it "initializes a new profile" do
        get :edit
        expect(assigns(:profile)).to be_a_new(Profile)
      end
    end
  end

  describe "PATCH #update" do
    context "when a profile exists" do
      let!(:profile) { Profile.create!(entity_type: :individual, first_name: "John", last_name: "Doe", email: "john@example.com", invoice_prefix: "INV", next_invoice_number: 1) }

      context "with valid params" do
        it "updates the profile" do
          patch :update, params: { profile: { first_name: "Jane" } }
          profile.reload
          expect(profile.first_name).to eq("Jane")
        end

        it "redirects to the edit page" do
          patch :update, params: { profile: { first_name: "Jane" } }
          expect(response).to redirect_to(edit_profile_path)
        end

        it "sets a success notice" do
          patch :update, params: { profile: { first_name: "Jane" } }
          expect(flash[:notice]).to eq('Profile was successfully updated.')
        end
      end

      context "with invalid params" do
        it "does not update the profile" do
          patch :update, params: { profile: { email: "invalid" } }
          profile.reload
          expect(profile.email).to eq("john@example.com")
        end

        it "renders the edit template" do
          patch :update, params: { profile: { email: "invalid" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when no profile exists" do
      context "with valid params" do
        it "creates a new profile" do
          expect {
            patch :update, params: { profile: { entity_type: :business, business_name: "Acme Corp", email: "info@acme.com", invoice_prefix: "INV", next_invoice_number: 1 } }
          }.to change(Profile, :count).by(1)
        end

        it "redirects to the edit page" do
          patch :update, params: { profile: { entity_type: :business, business_name: "Acme Corp", email: "info@acme.com", invoice_prefix: "INV", next_invoice_number: 1 } }
          expect(response).to redirect_to(edit_profile_path)
        end
      end

      context "with invalid params" do
        it "does not create a profile" do
          expect {
            patch :update, params: { profile: { entity_type: :business, email: "invalid" } }
          }.not_to change(Profile, :count)
        end

        it "renders the edit template" do
          patch :update, params: { profile: { entity_type: :business, email: "invalid" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end