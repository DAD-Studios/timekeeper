require 'rails_helper'

RSpec.describe "Clients", type: :request do
  let(:client) { create(:client) }

  describe "GET /index" do
    it "returns http success" do
      get clients_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get client_path(client)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_client_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_client_path(client)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new client" do
      expect {
        post clients_path, params: { client: attributes_for(:client) }
      }.to change(Client, :count).by(1)
      expect(response).to redirect_to(clients_path)
    end
  end

  describe "PATCH /update" do
    it "updates the client" do
      patch client_path(client), params: { client: { name: "Updated Name" } }
      expect(response).to redirect_to(clients_path)
      expect(client.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /destroy" do
    it "destroys the client" do
      client # create the client first
      expect {
        delete client_path(client)
      }.to change(Client, :count).by(-1)
      expect(response).to redirect_to(clients_path)
    end
  end

end
