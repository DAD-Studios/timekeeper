require 'rails_helper'

RSpec.feature "Time Entry Edit Form", type: :feature do
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

  scenario "editing an existing unpaid time entry shows time details and Update button", :skip do
    visit edit_time_entry_path(time_entry)

    # Should show time entry details
    expect(page).to have_content("Start Time")
    expect(page).to have_content("October 08, 2025 at 09:00 AM")

    expect(page).to have_content("End Time")
    expect(page).to have_content("October 08, 2025 at 11:30 AM")

    expect(page).to have_content("Duration")
    expect(page).to have_content("2.50 hours")

    expect(page).to have_content("Rate")
    expect(page).to have_content("$100.00 / hour")

    expect(page).to have_content("Earnings")
    expect(page).to have_content("$250.00")

    # Should have Update button, not Start Timer
    expect(page).to have_button("Update Time Entry")
    expect(page).not_to have_button("Start Timer")

    # Fields should be editable
    expect(page).to have_field("time_entry_client_id", disabled: false)
    expect(page).to have_field("time_entry_project_id", disabled: false)
  end

  scenario "editing a paid time entry shows time details with disabled fields", :skip do
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

    visit edit_time_entry_path(time_entry)

    # Should show warning
    expect(page).to have_content("This time entry is associated with a paid invoice")
    expect(page).to have_content("Only notes can be edited")

    # Should show time entry details
    expect(page).to have_content("Duration")
    expect(page).to have_content("2.50 hours")

    # Should have Update button
    expect(page).to have_button("Update Time Entry")
    expect(page).not_to have_button("Start Timer")

    # Non-notes fields should be disabled
    expect(page).to have_field("time_entry_client_id", disabled: true)
    expect(page).to have_field("time_entry_project_id", disabled: true)

    # Notes should be editable
    expect(page).to have_field("time_entry_notes", disabled: false)
  end

  scenario "creating a new time entry shows Start Timer button", :skip do
    visit new_time_entry_path

    # Should have Start Timer button, not Update
    expect(page).to have_button("Start Timer")
    expect(page).not_to have_button("Update Time Entry")

    # Should not show time entry details
    expect(page).not_to have_content("Start Time")
    expect(page).not_to have_content("End Time")
    expect(page).not_to have_content("Duration")
    expect(page).not_to have_content("Rate")
    expect(page).not_to have_content("Earnings")
  end
end
