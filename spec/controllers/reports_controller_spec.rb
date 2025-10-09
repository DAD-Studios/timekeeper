require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns the selected date" do
      get :index, params: { selected_date: '2023-10-26' }
      expect(assigns(:selected_date)).to eq(Date.parse('2023-10-26'))
    end

    it "defaults to current date when no date specified" do
      get :index
      expect(assigns(:selected_date)).to eq(Date.current)
    end

    it "assigns the current month" do
      get :index, params: { month: '2023-10-01' }
      expect(assigns(:current_month)).to eq(Date.parse('2023-10-01'))
    end

    it "assigns day metrics" do
      get :index
      expect(assigns(:day_metrics)).to be_a(Hash)
    end
  end
end
