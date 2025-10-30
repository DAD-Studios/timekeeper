require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should belong_to(:client) }
  it { should have_many(:time_entries).dependent(:destroy) }
  it { should have_many(:invoice_line_items).dependent(:nullify) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:rate).is_greater_than_or_equal_to(0) }

  describe 'validations' do
    let(:client) { create(:client) }
    before { create(:project, client: client) }
    it { should validate_uniqueness_of(:name).scoped_to(:client_id).case_insensitive }
  end

  describe 'cascade deletion' do
    let(:client) { Client.create!(name: 'Test Client', email: 'test@example.com') }
    let(:project) { client.projects.create!(name: 'Test Project', rate: 100) }

    before do
      # Create time entries
      @time_entry1 = client.time_entries.create!(
        project: project,
        task: 'Test Task 1',
        start_time: 2.hours.ago,
        end_time: 1.hour.ago,
        status: 'completed'
      )

      @time_entry2 = client.time_entries.create!(
        project: project,
        task: 'Test Task 2',
        start_time: 1.hour.ago,
        end_time: Time.current,
        status: 'completed'
      )

      # Create invoice with line items
      @invoice = client.invoices.create!(
        invoice_date: Date.current,
        due_date: Date.current + 30.days,
        status: :draft,
        subtotal: 200,
        total: 200
      )

      @line_item1 = @invoice.line_items.create!(
        time_entry: @time_entry1,
        project: project,
        description: 'Test line item 1',
        quantity: 1,
        rate: 100
      )

      @line_item2 = @invoice.line_items.create!(
        time_entry: @time_entry2,
        project: project,
        description: 'Test line item 2',
        quantity: 1,
        rate: 100
      )
    end

    it 'destroys all associated time entries' do
      time_entry1_id = @time_entry1.id
      time_entry2_id = @time_entry2.id
      project.destroy
      expect(TimeEntry.exists?(time_entry1_id)).to be false
      expect(TimeEntry.exists?(time_entry2_id)).to be false
    end

    it 'nullifies project_id in associated invoice line items' do
      line_item1_id = @line_item1.id
      line_item2_id = @line_item2.id
      project.destroy

      # Line items should still exist
      expect(InvoiceLineItem.exists?(line_item1_id)).to be true
      expect(InvoiceLineItem.exists?(line_item2_id)).to be true

      # But their project_id should be nil
      expect(InvoiceLineItem.find(line_item1_id).project_id).to be_nil
      expect(InvoiceLineItem.find(line_item2_id).project_id).to be_nil
    end

    it 'nullifies time_entry_id in invoice line items when time entries are destroyed' do
      line_item1_id = @line_item1.id
      project.destroy

      # Line item should exist but time_entry_id should be nil
      expect(InvoiceLineItem.exists?(line_item1_id)).to be true
      expect(InvoiceLineItem.find(line_item1_id).time_entry_id).to be_nil
    end

    it 'does not destroy the invoice' do
      invoice_id = @invoice.id
      project.destroy
      expect(Invoice.exists?(invoice_id)).to be true
    end

    it 'does not destroy invoice line items, only nullifies references' do
      line_item_count = @invoice.line_items.count
      project.destroy
      expect(@invoice.reload.line_items.count).to eq(line_item_count)
    end

    it 'leaves no time entry records after deletion' do
      initial_time_entry_count = TimeEntry.count
      project_time_entries_count = project.time_entries.count

      project.destroy

      expect(TimeEntry.count).to eq(initial_time_entry_count - project_time_entries_count)
    end
  end
end
