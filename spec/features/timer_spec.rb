require 'rails_helper'

RSpec.feature "Timer", type: :feature, js: true do
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:project) { Project.create!(name: "Test Project", client: client, rate: 100) }

  scenario "user starts and stops a timer" do
    visit root_path

    select client.name, from: "Client"

    # Wait for JavaScript to populate the project dropdown
    expect(page).to have_selector("select option", text: project.name, wait: 5)
    select project.name, from: "Project"

    click_link "New Task"
    fill_in "Task", with: "My new task"
    click_button "Start Timer"

    expect(page).to have_content("Running Timer")
    expect(page).to have_content("My new task")

    click_button "Stop"

    expect(page).to have_content("Timer stopped successfully.")
    expect(page).not_to have_content("Running Timer")
  end
end
