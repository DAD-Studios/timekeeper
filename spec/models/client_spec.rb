require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:time_entries).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates email format when present' do
      client = Client.new(name: 'Test Client', email: 'invalid')
      expect(client).not_to be_valid
      expect(client.errors[:email]).to include('is invalid')
    end

    it 'allows blank email' do
      client = Client.new(name: 'Test Client', email: '')
      expect(client).to be_valid
    end
  end

  describe '#full_address' do
    it 'returns formatted multi-line address' do
      client = Client.new(
        name: 'Test Client',
        address_line1: '456 Client Ave',
        address_line2: 'Floor 2',
        city: 'Dallas',
        state: 'TX',
        zip_code: '75201',
        country: 'USA'
      )
      expected = "456 Client Ave\nFloor 2\nDallas, TX, 75201\nUSA"
      expect(client.full_address).to eq(expected)
    end

    it 'handles missing address components' do
      client = Client.new(
        name: 'Test Client',
        address_line1: '456 Client Ave',
        city: 'Dallas'
      )
      expected = "456 Client Ave\nDallas\nUSA"
      expect(client.full_address).to eq(expected)
    end
  end

  describe 'cascade deletion' do
    let(:client) { Client.create!(name: 'Test Client', email: 'test@example.com') }
    let(:project) { client.projects.create!(name: 'Test Project', rate: 100) }

    before do
      # Create time entry
      @time_entry = client.time_entries.create!(
        project: project,
        task: 'Test Task',
        start_time: 1.hour.ago,
        end_time: Time.current,
        status: 'completed'
      )

      # Create invoice with line items and payments
      @invoice = client.invoices.create!(
        invoice_date: Date.current,
        due_date: Date.current + 30.days,
        status: :draft,
        subtotal: 100,
        total: 100
      )

      @line_item = @invoice.line_items.create!(
        time_entry: @time_entry,
        description: 'Test line item',
        quantity: 1,
        rate: 100
      )

      @payment = @invoice.payments.create!(
        amount: 50,
        payment_date: Date.current,
        payment_method: 'stripe'
      )
    end

    it 'destroys all associated projects' do
      project_id = project.id
      client.destroy
      expect(Project.exists?(project_id)).to be false
    end

    it 'destroys all associated time entries' do
      time_entry_id = @time_entry.id
      client.destroy
      expect(TimeEntry.exists?(time_entry_id)).to be false
    end

    it 'destroys all associated invoices' do
      invoice_id = @invoice.id
      client.destroy
      expect(Invoice.exists?(invoice_id)).to be false
    end

    it 'destroys all associated invoice line items' do
      line_item_id = @line_item.id
      client.destroy
      expect(InvoiceLineItem.exists?(line_item_id)).to be false
    end

    it 'destroys all associated invoice payments' do
      payment_id = @payment.id
      client.destroy
      expect(InvoicePayment.exists?(payment_id)).to be false
    end

    it 'leaves no orphaned records' do
      client_id = client.id
      project_id = project.id
      time_entry_id = @time_entry.id
      invoice_id = @invoice.id
      line_item_id = @line_item.id
      payment_id = @payment.id

      initial_counts = {
        clients: Client.count,
        projects: Project.count,
        time_entries: TimeEntry.count,
        invoices: Invoice.count,
        line_items: InvoiceLineItem.count,
        payments: InvoicePayment.count
      }

      client.destroy

      expect(Client.exists?(client_id)).to be false
      expect(Project.exists?(project_id)).to be false
      expect(TimeEntry.exists?(time_entry_id)).to be false
      expect(Invoice.exists?(invoice_id)).to be false
      expect(InvoiceLineItem.exists?(line_item_id)).to be false
      expect(InvoicePayment.exists?(payment_id)).to be false

      # Verify all related records were deleted
      expect(Client.count).to eq(initial_counts[:clients] - 1)
      expect(Project.count).to eq(initial_counts[:projects] - 1)
      expect(TimeEntry.count).to eq(initial_counts[:time_entries] - 1)
      expect(Invoice.count).to eq(initial_counts[:invoices] - 1)
      expect(InvoiceLineItem.count).to eq(initial_counts[:line_items] - 1)
      expect(InvoicePayment.count).to eq(initial_counts[:payments] - 1)
    end
  end
end
