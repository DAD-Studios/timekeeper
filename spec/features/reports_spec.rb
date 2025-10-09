require 'rails_helper'

RSpec.feature "Reports", type: :feature do
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:project) { Project.create!(name: "Test Project", client: client, rate: 100) }
  let!(:time_entry) do
    TimeEntry.create!(
      task: "Test Task",
      project: project,
      client: client,
      start_time: Date.current.beginning_of_day + 9.hours,
      end_time: Date.current.beginning_of_day + 10.hours,
      status: "completed",
      rate: 100
    )
  end

  scenario "user views the reports page" do
    visit reports_path

    expect(page).to have_content("Reports")
    expect(page).to have_content("Test Task")
    expect(page).to have_content("Duration")
    expect(page).to have_content("Earnings")
    expect(page).to have_content("$100.00")
  end
end
