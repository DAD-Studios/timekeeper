require 'rails_helper'

RSpec.describe "TimeEntry Paid Restrictions", type: :request do
  let(:profile) { Profile.create!(
    entity_type: 'individual',
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    invoice_prefix: "INV",
    next_invoice_number: 1
  ) }
  let(:client) { Client.create!(name: "Test Client") }
  let(:project) { Project.create!(name: "Test Project", client: client, rate: 100) }
  let(:time_entry) { TimeEntry.create!(
    client: client,
    project: project,
    task: "Original Task",
    status: 'completed',
    start_time: 1.hour.ago,
    end_time: Time.current
  ) }
  let(:paid_invoice) { Invoice.create!(
    client: client,
    invoice_number: "INV-001",
    invoice_date: Date.current,
    due_date: Date.current + 30.days,
    status: 'paid',
    paid_date: Date.current
  ) }

  describe "updating a paid time entry" do
    before do
      InvoiceLineItem.create!(
        invoice: paid_invoice,
        time_entry: time_entry,
        description: time_entry.task,
        quantity: time_entry.duration_in_hours,
        rate: time_entry.rate,
        amount: time_entry.earnings
      )
    end

    it "only allows updating notes field" do
      patch time_entry_path(time_entry), params: {
        time_entry: {
          notes: "Updated notes",
          task: "New Task"
        }
      }

      expect(response).to redirect_to(time_entries_path)
      expect(flash[:notice]).to match(/notes were successfully updated/)

      time_entry.reload
      expect(time_entry.notes.to_plain_text).to eq("Updated notes")
      expect(time_entry.task).to eq("Original Task") # Should not change
    end

    it "does not allow changing task" do
      patch time_entry_path(time_entry), params: {
        time_entry: { task: "New Task" }
      }

      time_entry.reload
      expect(time_entry.task).to eq("Original Task")
    end

    it "does not allow changing project" do
      new_project = Project.create!(name: "New Project", client: client, rate: 150)

      patch time_entry_path(time_entry), params: {
        time_entry: { project_id: new_project.id }
      }

      time_entry.reload
      expect(time_entry.project_id).to eq(project.id)
    end

    it "does not allow changing client" do
      new_client = Client.create!(name: "New Client")

      patch time_entry_path(time_entry), params: {
        time_entry: { client_id: new_client.id }
      }

      time_entry.reload
      expect(time_entry.client_id).to eq(client.id)
    end
  end

  describe "updating an unpaid time entry" do
    it "allows updating all fields" do
      new_client = Client.create!(name: "New Client")
      new_project = Project.create!(name: "New Project", client: new_client, rate: 150)

      patch time_entry_path(time_entry), params: {
        time_entry: {
          task: "New Task",
          project_id: new_project.id,
          client_id: new_client.id,
          notes: "Updated notes"
        }
      }

      expect(response).to redirect_to(time_entries_path)
      expect(flash[:notice]).to match(/successfully updated/)

      time_entry.reload
      expect(time_entry.task).to eq("New Task")
      expect(time_entry.project_id).to eq(new_project.id)
      expect(time_entry.client_id).to eq(new_client.id)
      expect(time_entry.notes.to_plain_text).to eq("Updated notes")
    end
  end
end
