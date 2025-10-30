require 'rails_helper'

RSpec.feature "Profile Management", type: :feature do
  scenario "user creates an individual profile" do
    visit edit_profile_path

    choose "Individual"
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Doe"
    fill_in "Email", with: "john@example.com"
    fill_in "Phone", with: "555-1234"
    fill_in "Address line1", with: "123 Main St"
    fill_in "City", with: "Austin"
    fill_in "State", with: "TX"
    fill_in "Zip code", with: "78701"
    fill_in "Country", with: "USA"
    fill_in "Invoice prefix", with: "INV"
    fill_in "Next invoice number", with: "1"
    fill_in "Payment Terms (days)", with: "30"

    click_button "Save Profile"

    expect(page).to have_content("Profile was successfully updated.")

    profile = Profile.first
    expect(profile.individual?).to be true
    expect(profile.first_name).to eq("John")
    expect(profile.last_name).to eq("Doe")
    expect(profile.email).to eq("john@example.com")
  end

  scenario "user creates a business profile", js: true do
    visit edit_profile_path

    # The Entity Type section might be collapsed, so expand it first
    # Look for the Entity Type heading and click it if needed
    unless page.has_css?('label', text: 'Business', visible: true)
      find('h2', text: 'Entity Type').click
      sleep 0.5 # Give the animation time to complete
    end

    # Click on the label text "Business" which will trigger the radio button
    find('label', text: 'Business').click

    # The Business Information section might also be collapsed, expand it
    sleep 0.5 # Wait for the JavaScript to show/hide sections
    unless page.has_field?("Business name", visible: true)
      find('h2', text: 'Business Information').click
      sleep 0.5
    end

    # Wait for the business fields to become visible
    expect(page).to have_field("Business name", wait: 5)

    fill_in "Business name", with: "Acme Corporation"
    fill_in "Tax ID / EIN", with: "12-3456789"

    # Expand Contact Information section
    unless page.has_field?("Email", visible: true)
      find('h2', text: 'Contact Information').click
      sleep 0.5
    end

    fill_in "Email", with: "info@acme.com"
    fill_in "Phone", with: "555-9999"

    # Expand Address section
    unless page.has_field?("Address line1", visible: true)
      find('h2', text: /^Address$/).click
      sleep 0.5
    end

    fill_in "Address line1", with: "456 Business Blvd"
    fill_in "City", with: "Dallas"
    fill_in "State", with: "TX"
    fill_in "Zip code", with: "75201"
    fill_in "Country", with: "USA"

    # Expand Invoice Settings section
    unless page.has_field?("Invoice prefix", visible: true)
      invoice_settings_header = find('h2', text: 'Invoice Settings')
      page.execute_script("arguments[0].click();", invoice_settings_header)
      sleep 0.5
    end

    fill_in "Invoice prefix", with: "ACME"
    fill_in "Next invoice number", with: "100"

    click_button "Save Profile"

    expect(page).to have_content("Profile was successfully updated.")

    profile = Profile.first
    expect(profile.business?).to be true
    expect(profile.business_name).to eq("Acme Corporation")
    expect(profile.tax_id).to eq("12-3456789")
    expect(profile.email).to eq("info@acme.com")
  end

  scenario "user updates an existing profile" do
    Profile.create!(
      entity_type: :individual,
      first_name: "Jane",
      last_name: "Smith",
      email: "jane@example.com",
      invoice_prefix: "JS",
      next_invoice_number: 1
    )

    visit edit_profile_path

    fill_in "First name", with: "Janet"
    fill_in "Last name", with: "Smithson"

    click_button "Save Profile"

    expect(page).to have_content("Profile was successfully updated.")

    profile = Profile.first
    expect(profile.first_name).to eq("Janet")
    expect(profile.last_name).to eq("Smithson")
  end

  scenario "validation errors prevent saving" do
    visit edit_profile_path

    choose "Individual"
    fill_in "Email", with: "invalid-email"
    fill_in "Invoice prefix", with: "INV"
    fill_in "Next invoice number", with: "1"

    click_button "Save Profile"

    expect(page).to have_content("prohibited this profile from being saved")
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
    expect(page).to have_content("Email is invalid")
  end
end
