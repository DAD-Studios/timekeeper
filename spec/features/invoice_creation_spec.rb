require 'rails_helper'

RSpec.feature "Invoice Creation", type: :feature do
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

  scenario "user creates an invoice with time entries" do
    visit new_invoice_path

    # Select client
    select client.name, from: "Client"

    # Give JavaScript time to load time entries
    sleep 1

    # Verify we can see the time entries section
    expect(page).to have_content("Select Time Entries")
    expect(page).to have_content("Task 1")
    expect(page).to have_content("Task 2")

    # Check the checkboxes for both time entries
    all('input[type="checkbox"]').each(&:check)

    # Give JavaScript time to add line items
    sleep 1

    # Fill in other fields
    fill_in "invoice_invoice_date", with: Date.current
    fill_in "invoice_due_date", with: (Date.current + 30.days)

    # Submit the form
    click_button "Create Invoice"

    # Verify success
    expect(page).to have_content("Invoice was successfully created")

    # Verify the invoice has the line items
    invoice = Invoice.last
    expect(invoice.line_items.count).to eq(2)
    expect(invoice.line_items.map(&:time_entry_id)).to contain_exactly(time_entry1.id, time_entry2.id)

    # Verify time entries are now associated with the invoice
    expect(time_entry1.reload.invoice).to eq(invoice)
    expect(time_entry2.reload.invoice).to eq(invoice)
  end

  scenario "user creates invoice with manual line item" do
    visit new_invoice_path

    select client.name, from: "Client"

    # Click add manual line item
    click_button "Add Manual Line Item"

    # Fill in the line item
    within all('.line-item-row').last do
      fill_in "Description", with: "Custom service"
      fill_in "Hours", with: "5"
      fill_in "Rate", with: "150"
    end

    fill_in "invoice_invoice_date", with: Date.current
    fill_in "invoice_due_date", with: (Date.current + 30.days)

    click_button "Create Invoice"

    expect(page).to have_content("Invoice was successfully created")

    invoice = Invoice.last
    expect(invoice.line_items.count).to eq(1)
    expect(invoice.line_items.first.description).to eq("Custom service")
    expect(invoice.line_items.first.quantity).to eq(5.0)
    expect(invoice.line_items.first.rate).to eq(150.0)
  end
end
