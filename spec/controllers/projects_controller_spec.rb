require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:client) { Client.create!(name: "Test Client") }
  let(:project) { Project.create!(name: "Test Project", client: client, rate: 50.00) }

  before do
    # Stub the set_clients before_action
    allow(controller).to receive(:set_clients)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, params: { project: { name: "New Project", client_id: client.id, rate: 60.00 } }
        }.to change(Project, :count).by(1)
      end

      it "redirects to the projects list" do
        post :create, params: { project: { name: "New Project", client_id: client.id, rate: 60.00 } }
        expect(response).to redirect_to(projects_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { project: { name: "", rate: 60.00 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested project" do
        put :update, params: { id: project.to_param, project: { name: "Updated Project", rate: 70.00 } }
        project.reload
        expect(project.name).to eq("Updated Project")
        expect(project.rate).to eq(70.00)
      end

      it "redirects to the projects list" do
        put :update, params: { id: project.to_param, project: { name: "Updated Project", rate: 70.00 } }
        expect(response).to redirect_to(projects_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: project.to_param, project: { name: "", rate: 70.00 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested project" do
      project_to_destroy = Project.create!(name: "To Be Destroyed", client: client, rate: 80.00)
      expect {
        delete :destroy, params: { id: project_to_destroy.to_param }
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      delete :destroy, params: { id: project.to_param }
      expect(response).to redirect_to(projects_url)
    end
  end
end
