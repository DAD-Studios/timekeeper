require 'rails_helper'

RSpec.describe "TimeEntry Edit Page Rendering", type: :request do
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
    task: "Test Task",
    status: 'completed',
    start_time: Time.new(2025, 10, 8, 9, 0, 0),
    end_time: Time.new(2025, 10, 8, 11, 30, 0)
  ) }

  describe "GET /time_entries/:id/edit" do
    it "renders successfully for unpaid time entry" do
      get edit_time_entry_path(time_entry)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Update Time Entry")
      expect(response.body).to include("Start Time")
      expect(response.body).to include("End Time")
      expect(response.body).to include("Duration")
      expect(response.body).to include("2.50 hours")
    end

    it "renders successfully for paid time entry" do
      paid_invoice = Invoice.create!(
        client: client,
        invoice_number: "INV-001",
        invoice_date: Date.current,
        due_date: Date.current + 30.days,
        status: 'paid',
        paid_date: Date.current
      )

      InvoiceLineItem.create!(
        invoice: paid_invoice,
        time_entry: time_entry,
        description: time_entry.task,
        quantity: time_entry.duration_in_hours,
        rate: time_entry.rate,
        amount: time_entry.earnings
      )

      get edit_time_entry_path(time_entry)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("This time entry is associated with a paid invoice")
      expect(response.body).to include("Only notes can be edited")
      expect(response.body).to include("Update Time Entry")
    end
  end
end
