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
        expect(response).to have_http_status(:unprocessable_content)
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
        expect(response).to have_http_status(:unprocessable_content)
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

    it "sets a success notice with deletion details" do
      delete :destroy, params: { id: project.to_param }
      expect(flash[:notice]).to include(project.name)
      expect(flash[:notice]).to include('successfully deleted')
    end

    context 'with associated time entries' do
      let(:project_with_data) { Project.create!(name: "Project with Data", client: client, rate: 100.00) }

      before do
        @time_entry1 = client.time_entries.create!(
          project: project_with_data,
          task: 'Test Task 1',
          start_time: 2.hours.ago,
          end_time: 1.hour.ago,
          status: 'completed'
        )

        @time_entry2 = client.time_entries.create!(
          project: project_with_data,
          task: 'Test Task 2',
          start_time: 1.hour.ago,
          end_time: Time.current,
          status: 'completed'
        )
      end

      it 'cascades delete to all associated time entries' do
        time_entry1_id = @time_entry1.id
        time_entry2_id = @time_entry2.id

        delete :destroy, params: { id: project_with_data.to_param }

        expect(TimeEntry.exists?(time_entry1_id)).to be false
        expect(TimeEntry.exists?(time_entry2_id)).to be false
      end

      it 'includes time entry count in the notice' do
        delete :destroy, params: { id: project_with_data.to_param }
        expect(flash[:notice]).to include('2 associated time entry/entries')
      end
    end

    context 'with associated invoice line items' do
      let(:project_with_invoice) { Project.create!(name: "Project with Invoice", client: client, rate: 100.00) }

      before do
        @time_entry = client.time_entries.create!(
          project: project_with_invoice,
          task: 'Test Task',
          start_time: 1.hour.ago,
          end_time: Time.current,
          status: 'completed'
        )

        @invoice = client.invoices.create!(
          invoice_date: Date.current,
          due_date: Date.current + 30.days,
          status: :draft,
          subtotal: 100,
          total: 100
        )

        @line_item = @invoice.line_items.create!(
          time_entry: @time_entry,
          project: project_with_invoice,
          description: 'Test line item',
          quantity: 1,
          rate: 100
        )
      end

      it 'nullifies project_id in invoice line items' do
        line_item_id = @line_item.id

        delete :destroy, params: { id: project_with_invoice.to_param }

        expect(InvoiceLineItem.exists?(line_item_id)).to be true
        expect(InvoiceLineItem.find(line_item_id).project_id).to be_nil
      end

      it 'does not destroy the invoice' do
        invoice_id = @invoice.id

        delete :destroy, params: { id: project_with_invoice.to_param }

        expect(Invoice.exists?(invoice_id)).to be true
      end

      it 'does not destroy invoice line items' do
        line_item_id = @line_item.id

        delete :destroy, params: { id: project_with_invoice.to_param }

        expect(InvoiceLineItem.exists?(line_item_id)).to be true
      end
    end
  end
end
