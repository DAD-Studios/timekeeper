require 'rails_helper'

RSpec.describe TimeEntriesController, type: :controller do
  let(:client) { Client.create!(name: "Test Client") }
  let(:project) { Project.create!(name: "Test Project", client: client, rate: 100) }
  let(:time_entry) { TimeEntry.create!(task: "Test Task", project: project, client: client, status: 'completed', start_time: 1.hour.ago, end_time: 30.minutes.ago) }

  before do
    # Stub the set_select_collections before_action
    allow(controller).to receive(:set_select_collections)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
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
      get :edit, params: { id: time_entry.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TimeEntry" do
        expect {
          post :create, params: { time_entry: { task: "New Task", project_id: project.id, client_id: client.id } }
        }.to change(TimeEntry, :count).by(1)
      end

      it "redirects to the root path" do
        post :create, params: { time_entry: { task: "New Task", project_id: project.id, client_id: client.id } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { time_entry: { task: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with new client" do
      it "creates a new client and time entry" do
        # Reference project to ensure existing client/project are created
        existing_project = project

        expect {
          post :create, params: {
            time_entry: {
              task: "New Task",
              project_id: existing_project.id,
              new_client_name: "New Client"
            }
          }
        }.to change(Client, :count).by(1)
         .and change(TimeEntry, :count).by(1)

        new_client = Client.find_by(name: "New Client")
        expect(new_client).to be_present
        expect(TimeEntry.last.client).to eq(new_client)
      end

      it "uses existing client if name already exists" do
        # Reference project to ensure existing client/project are created
        existing_project = project
        existing_client = client

        expect {
          post :create, params: {
            time_entry: {
              task: "New Task",
              project_id: existing_project.id,
              new_client_name: existing_client.name
            }
          }
        }.to change(Client, :count).by(0)
         .and change(TimeEntry, :count).by(1)

        expect(TimeEntry.last.client).to eq(existing_client)
      end
    end

    context "with new project" do
      it "creates a new project and time entry" do
        expect {
          post :create, params: {
            time_entry: {
              task: "New Task",
              client_id: client.id,
              new_project_name: "New Project",
              new_project_rate: "75.50"
            }
          }
        }.to change(Project, :count).by(1)
         .and change(TimeEntry, :count).by(1)

        expect(Project.last.name).to eq("New Project")
        expect(Project.last.rate).to eq(75.50)
        expect(Project.last.client).to eq(client)
        expect(TimeEntry.last.project).to eq(Project.last)
      end

      it "uses existing project if name already exists for that client" do
        existing = Project.create!(name: "Existing Project", client: client, rate: 100)
        expect {
          post :create, params: {
            time_entry: {
              task: "New Task",
              client_id: client.id,
              new_project_name: "Existing Project",
              new_project_rate: "75.50"
            }
          }
        }.to change(Project, :count).by(0)
         .and change(TimeEntry, :count).by(1)

        expect(TimeEntry.last.project).to eq(existing)
      end

      it "defaults rate to 0 if not provided" do
        post :create, params: {
          time_entry: {
            task: "New Task",
            client_id: client.id,
            new_project_name: "No Rate Project"
          }
        }

        expect(Project.last.rate).to eq(0)
      end
    end

    context "with new client and new project" do
      it "creates both and associates them correctly" do
        expect {
          post :create, params: {
            time_entry: {
              task: "New Task",
              new_client_name: "Brand New Client",
              new_project_name: "Brand New Project",
              new_project_rate: "90.00"
            }
          }
        }.to change(Client, :count).by(1)
         .and change(Project, :count).by(1)
         .and change(TimeEntry, :count).by(1)

        new_client = Client.last
        new_project = Project.last
        new_time_entry = TimeEntry.last

        expect(new_client.name).to eq("Brand New Client")
        expect(new_project.name).to eq("Brand New Project")
        expect(new_project.rate).to eq(90.00)
        expect(new_project.client).to eq(new_client)
        expect(new_time_entry.client).to eq(new_client)
        expect(new_time_entry.project).to eq(new_project)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested time_entry" do
        put :update, params: { id: time_entry.to_param, time_entry: { task: "Updated Task" } }
        time_entry.reload
        expect(time_entry.task).to eq("Updated Task")
      end

      it "redirects to the time_entries list" do
        put :update, params: { id: time_entry.to_param, time_entry: { task: "Updated Task" } }
        expect(response).to redirect_to(time_entries_path)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: time_entry.to_param, time_entry: { task: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested time_entry" do
      time_entry_to_destroy = TimeEntry.create!(task: "To Be Destroyed", project: project, client: client, status: 'completed', start_time: 1.hour.ago, end_time: 30.minutes.ago)
      expect {
        delete :destroy, params: { id: time_entry_to_destroy.to_param }
      }.to change(TimeEntry, :count).by(-1)
    end

    it "redirects to the time_entries list" do
      delete :destroy, params: { id: time_entry.to_param }
      expect(response).to redirect_to(time_entries_path)
    end
  end

  describe "PATCH #stop" do
    let(:running_time_entry) { TimeEntry.create!(task: "Running Task", project: project, client: client, status: 'running', start_time: 1.hour.ago) }

    it "stops the running time entry" do
      patch :stop, params: { id: running_time_entry.to_param }
      running_time_entry.reload
      expect(running_time_entry.status).to eq('completed')
    end

    it "redirects to the root path" do
      patch :stop, params: { id: running_time_entry.to_param }
      expect(response).to redirect_to(root_path)
    end
  end
end
