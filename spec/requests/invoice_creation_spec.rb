require 'rails_helper'

RSpec.describe "Invoice Creation", type: :request do
  let!(:profile) { Profile.create!(
    entity_type: 'individual',
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    invoice_prefix: "INV",
    next_invoice_number: 1
  ) }
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:project) { Project.create!(name: "Test Project", client: client, rate: 100) }
  let!(:time_entry1) { TimeEntry.create!(
    client: client,
    project: project,
    task: "Task 1",
    start_time: 2.hours.ago,
    end_time: 1.hour.ago,
    status: 'completed',
    rate: 100
  ) }
  let!(:time_entry2) { TimeEntry.create!(
    client: client,
    project: project,
    task: "Task 2",
    start_time: 4.hours.ago,
    end_time: 2.hours.ago,
    status: 'completed',
    rate: 100
  ) }

  describe "POST /invoices" do
    it "creates an invoice with time entries" do
      invoice_params = {
        invoice: {
          client_id: client.id,
          invoice_date: Date.current,
          due_date: Date.current + 30.days,
          discount_amount: 0,
          line_items_attributes: {
            "0" => {
              time_entry_id: time_entry1.id,
              description: time_entry1.task,
              quantity: time_entry1.duration_in_hours,
              rate: time_entry1.rate
            },
            "1" => {
              time_entry_id: time_entry2.id,
              description: time_entry2.task,
              quantity: time_entry2.duration_in_hours,
              rate: time_entry2.rate
            }
          }
        }
      }

      expect {
        post invoices_path, params: invoice_params
      }.to change(Invoice, :count).by(1)
       .and change(InvoiceLineItem, :count).by(2)

      invoice = Invoice.last
      expect(invoice.line_items.count).to eq(2)
      expect(invoice.line_items.pluck(:time_entry_id)).to contain_exactly(time_entry1.id, time_entry2.id)

      # Verify time entries are associated with invoice
      expect(time_entry1.reload.invoice).to eq(invoice)
      expect(time_entry2.reload.invoice).to eq(invoice)
    end

    it "creates an invoice with manual line items" do
      invoice_params = {
        invoice: {
          client_id: client.id,
          invoice_date: Date.current,
          due_date: Date.current + 30.days,
          discount_amount: 0,
          line_items_attributes: {
            "0" => {
              description: "Custom service",
              quantity: 5,
              rate: 150
            }
          }
        }
      }

      expect {
        post invoices_path, params: invoice_params
      }.to change(Invoice, :count).by(1)
       .and change(InvoiceLineItem, :count).by(1)

      invoice = Invoice.last
      line_item = invoice.line_items.first

      expect(line_item.description).to eq("Custom service")
      expect(line_item.quantity).to eq(5.0)
      expect(line_item.rate).to eq(150.0)
      expect(line_item.time_entry_id).to be_nil
    end
  end
end
