require 'rails_helper'

RSpec.describe "Invoices", type: :request do
  let(:invoice) { create(:invoice) }

  describe "GET /index" do
    it "returns http success" do
      get invoices_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get invoice_path(invoice)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_invoice_path
      expect(response).to have_http_status(:success)
    end
  end

end
