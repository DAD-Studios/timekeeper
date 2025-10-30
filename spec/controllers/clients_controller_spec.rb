require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let(:valid_attributes) do
    {
      name: 'Test Client',
      email: 'test@example.com',
      first_name: 'John',
      last_name: 'Doe',
      phone: '555-1234'
    }
  end

  let(:client) { Client.create!(valid_attributes) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: client.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: client.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Client' do
        expect {
          post :create, params: { client: valid_attributes }
        }.to change(Client, :count).by(1)
      end

      it 'redirects to the clients index' do
        post :create, params: { client: valid_attributes }
        expect(response).to redirect_to(clients_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Client' do
        expect {
          post :create, params: { client: { name: '' } }
        }.not_to change(Client, :count)
      end

      it 'renders the new template' do
        post :create, params: { client: { name: '' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Client Name' } }

      it 'updates the requested client' do
        patch :update, params: { id: client.id, client: new_attributes }
        client.reload
        expect(client.name).to eq('Updated Client Name')
      end

      it 'redirects to the clients index' do
        patch :update, params: { id: client.id, client: new_attributes }
        expect(response).to redirect_to(clients_url)
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template' do
        patch :update, params: { id: client.id, client: { name: '' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:client_to_delete) { Client.create!(valid_attributes) }

    it 'destroys the requested client' do
      expect {
        delete :destroy, params: { id: client_to_delete.id }
      }.to change(Client, :count).by(-1)
    end

    it 'redirects to the clients list' do
      delete :destroy, params: { id: client_to_delete.id }
      expect(response).to redirect_to(clients_url)
    end

    it 'sets a success notice with deletion details' do
      delete :destroy, params: { id: client_to_delete.id }
      expect(flash[:notice]).to include(valid_attributes[:name])
      expect(flash[:notice]).to include('successfully deleted')
    end

    context 'with associated data' do
      let(:project) { client_to_delete.projects.create!(name: 'Test Project', rate: 100) }

      before do
        # Create time entry
        @time_entry = client_to_delete.time_entries.create!(
          project: project,
          task: 'Test Task',
          start_time: 1.hour.ago,
          end_time: Time.current,
          status: 'completed'
        )

        # Create invoice with payments
        @invoice = client_to_delete.invoices.create!(
          invoice_date: Date.current,
          due_date: Date.current + 30.days,
          status: :draft,
          subtotal: 100,
          total: 100
        )

        @payment = @invoice.payments.create!(
          amount: 50,
          payment_date: Date.current,
          payment_method: 'stripe'
        )
      end

      it 'cascades delete to all associated projects' do
        project_id = project.id
        delete :destroy, params: { id: client_to_delete.id }
        expect(Project.exists?(project_id)).to be false
      end

      it 'cascades delete to all associated time entries' do
        time_entry_id = @time_entry.id
        delete :destroy, params: { id: client_to_delete.id }
        expect(TimeEntry.exists?(time_entry_id)).to be false
      end

      it 'cascades delete to all associated invoices' do
        invoice_id = @invoice.id
        delete :destroy, params: { id: client_to_delete.id }
        expect(Invoice.exists?(invoice_id)).to be false
      end

      it 'cascades delete to all associated payments' do
        payment_id = @payment.id
        delete :destroy, params: { id: client_to_delete.id }
        expect(InvoicePayment.exists?(payment_id)).to be false
      end

      it 'includes deletion counts in the notice' do
        delete :destroy, params: { id: client_to_delete.id }
        expect(flash[:notice]).to include('1 projects')
        expect(flash[:notice]).to include('1 time entries')
        expect(flash[:notice]).to include('1 invoices')
      end
    end
  end
end
