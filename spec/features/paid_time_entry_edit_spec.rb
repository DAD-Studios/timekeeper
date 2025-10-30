require 'rails_helper'

RSpec.feature "Paid Time Entry Editing", type: :feature do
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

  scenario "user sees disabled fields when editing paid time entry" do
    InvoiceLineItem.create!(
      invoice: paid_invoice,
      time_entry: time_entry,
      description: time_entry.task,
      quantity: time_entry.duration_in_hours,
      rate: time_entry.rate,
      amount: time_entry.earnings
    )

    visit edit_time_entry_path(time_entry)

    # Should show warning message
    expect(page).to have_content("This time entry is associated with a paid invoice")
    expect(page).to have_content("Only notes can be edited")

    # Check that fields are disabled
    expect(page).to have_field("time_entry_client_id", disabled: true)
    expect(page).to have_field("time_entry_project_id", disabled: true)

    # Notes field should be enabled
    expect(page).to have_css("lexxy-editor")

    # Should not show "New Client", "New Project", or "New Task" links
    expect(page).not_to have_link("New Client")
    expect(page).not_to have_link("New Project")
    expect(page).not_to have_link("New Task")
  end

  scenario "user can edit all fields for unpaid time entry" do
    visit edit_time_entry_path(time_entry)

    # Should not show warning message
    expect(page).not_to have_content("This time entry is associated with a paid invoice")

    # Check that fields are enabled
    expect(page).to have_field("time_entry_client_id", disabled: false)
    expect(page).to have_field("time_entry_project_id", disabled: false)

    # Should show "New Client", "New Project", and "New Task" links
    expect(page).to have_link("New Client")
    expect(page).to have_link("New Project")
    expect(page).to have_link("New Task")
  end
end
