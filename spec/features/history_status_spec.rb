require 'rails_helper'

RSpec.feature "History Page Status", type: :feature do
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
  let!(:unbilled_entry) { TimeEntry.create!(
    client: client,
    project: project,
    task: "Test Task",
    start_time: 2.hours.ago,
    end_time: 1.hour.ago,
    status: 'completed',
    rate: 100
  ) }

  scenario "displays unbilled status for time entries without invoices" do
    visit time_entries_path

    expect(page).to have_content("Unbilled")
    expect(page).to have_selector("i.bi-clock")
  end

  scenario "displays invoiced status for time entries with invoices" do
    # Create an invoice with the time entry
    invoice = Invoice.create!(
      client: client,
      invoice_number: "INV-001",
      invoice_date: Date.current,
      due_date: 30.days.from_now,
      status: 'draft'
    )

    InvoiceLineItem.create!(
      invoice: invoice,
      time_entry: unbilled_entry,
      description: "Test work",
      quantity: 1,
      rate: 100,
      amount: 100
    )

    visit time_entries_path

    expect(page).to have_content("Invoiced")
    expect(page).to have_selector("i.bi-check-circle")
    expect(page).not_to have_content("Unbilled")
    expect(page).not_to have_content("Paid")
  end

  scenario "displays paid status for time entries with paid invoices" do
    # Create a paid invoice with the time entry
    invoice = Invoice.create!(
      client: client,
      invoice_number: "INV-002",
      invoice_date: Date.current,
      due_date: 30.days.from_now,
      status: 'paid'
    )

    InvoiceLineItem.create!(
      invoice: invoice,
      time_entry: unbilled_entry,
      description: "Test work",
      quantity: 1,
      rate: 100,
      amount: 100
    )

    visit time_entries_path

    expect(page).to have_content("Paid")
    expect(page).to have_selector("i.bi-cash-coin")
    expect(page).not_to have_content("Unbilled")
    expect(page).not_to have_content("Invoiced")
  end
end
