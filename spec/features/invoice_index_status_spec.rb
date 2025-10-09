require 'rails_helper'

RSpec.feature "Invoice Index Status Updates", type: :feature do
  let!(:profile) { Profile.create!(
    entity_type: 'individual',
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    invoice_prefix: "INV",
    next_invoice_number: 1
  ) }
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:invoice) { Invoice.create!(
    client: client,
    invoice_number: "INV-001",
    invoice_date: Date.current,
    due_date: Date.current + 30.days,
    status: 'draft'
  ) }

  scenario "user sees status dropdown on index page" do
    visit invoices_path

    # Verify the status dropdown is present and shows current status
    expect(page).to have_select("invoice_status_#{invoice.id}", selected: "Draft")

    # Verify all status options are available
    within "#invoice_status_#{invoice.id}" do
      expect(page).to have_content("Draft")
      expect(page).to have_content("Sent")
      expect(page).to have_content("Paid")
    end
  end
end
